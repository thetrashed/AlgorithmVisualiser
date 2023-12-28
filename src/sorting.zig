// All sorting functions take as an argument a compare function, which should
// return 1, 0, or -1 based on the following:
// -  1: compareFn(x, y) -> x > y
// -  0: compareFn(x, y) -> x == y
// - -1: compareFn(x, y) -> x < y
const std = @import("std");
const array = @import("customArray.zig");

pub fn insertionSort(
    comptime T: type,
    data_array: *array.AnimatedArray(T),
) void {
    var i: usize = 1;
    while (i < data_array.data.items.len) : (i += 1) {
        data_array.current_elem = data_array.getValPtr(i);

        if (data_array.compareData(
            data_array.getVal(i),
            data_array.getVal(i - 1),
        ) == 1) continue;

        var j = i - 1;
        var original_i = i;
        while (true) {
            data_array.current_elem = data_array.getValPtr(i);
            if (data_array.compareData(
                data_array.getVal(i),
                data_array.getVal(j),
            ) == -1) {
                var k = i;
                while (k > j) : (k -= 1) {
                    if (!data_array.swapVals(k, k - 1)) return;
                    data_array.current_elem = data_array.getValPtr(k);
                }
                i -= 1;
            } else {
                break;
            }

            if (j == 0) {
                break;
            }
            j -= 1;
        }
        i = original_i;
    }
}

fn merge(
    comptime T: type,
    data_array: *array.AnimatedArray(T),
    sindex: usize,
    midpoint: usize,
    eindex: usize,
) !bool {
    const left_len = midpoint;
    const right_len = eindex - (sindex + midpoint);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const tmpBuf1 = try allocator.alloc(T, left_len);
    defer allocator.free(tmpBuf1);
    const tmpBuf2 = try allocator.alloc(T, right_len);
    defer allocator.free(tmpBuf2);

    std.mem.copyForwards(
        T,
        tmpBuf1,
        data_array.data.items[sindex..sindex + left_len],
    );
    std.mem.copyForwards(
        T,
        tmpBuf2,
        data_array.data.items[sindex + midpoint .. sindex + midpoint + right_len],
    );
    data_array.access_count += right_len + left_len;

    var comp_result: i32 = undefined;

    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;

    while (i < left_len and j < right_len) {
        data_array.current_elem = data_array.getValPtr(k + sindex);
        comp_result = data_array.compareData(tmpBuf1[i], tmpBuf2[j]);
        data_array.access_count += 1;

        switch (comp_result) {
            0, -1 => {
                if (!data_array.putVal(k + sindex, tmpBuf1[i])) {
                    return false;
                }
                i += 1;
            },
            1 => {
                if (!data_array.putVal(k + sindex, tmpBuf2[j])) {
                    return false;
                }
                j += 1;
            },
            else => unreachable,
        }

        k += 1;
    }

    while (i < left_len) {
        if (!data_array.putVal(k + sindex, tmpBuf1[i])) {
            return false;
        }

        i += 1;
        k += 1;
    }

    while (j < right_len) {
        if (!data_array.putVal(k + sindex, tmpBuf2[j])) {
            return false;
        }

        j += 1;
        k += 1;
    }

    return true;
}

pub fn mergeSort(
    comptime T: type,
    data_array: *array.AnimatedArray(T),
    start_index: usize,
    end_index: usize,
) !void {
    const len = end_index - start_index;
    var flag: bool = true;

    switch (len) {
        1 => {},
        else => {
            const midpoint = 1 + (len - 1) / 2;
            try mergeSort(T, data_array, start_index, start_index + midpoint);

            try mergeSort(T, data_array, start_index + midpoint, end_index);

            flag = try merge(
                T,
                data_array,
                start_index,
                midpoint,
                end_index,
            );
            if (!flag) {
                return;
            }
        },
    }
}
