const std = @import("std");
const raylib = @import("raylib.zig");

pub fn AnimatedArray(comptime T: type) type {
    return struct {
        data: std.ArrayList(T),
        access_count: usize,
        comparison_count: usize,
        allocator: std.mem.Allocator,

        current_elem: *const T,

        const This = @This();
        pub fn init(allocator: std.mem.Allocator) This {
            return .{
                .data = std.ArrayList(T).init(allocator),
                .access_count = 0,
                .comparison_count = 0,
                .allocator = allocator,

                .current_elem = undefined,
            };
        }

        pub fn getVal(this: *This, index: usize) T {
            this.access_count += 1;
            return this.data.items[index];
        }

        pub fn getValPtr(this: *This, index: usize) *T {
            this.access_count += 1;
            return &this.data.items[index];
        }

        pub fn putVal(this: *This, index: usize, value: T) bool {
            this.access_count += 1;
            this.data.items[index] = value;
            return this.updateAnim();
        }

        pub fn swapVals(this: *This, index1: usize, index2: usize) bool {
            var tmp: T = this.data.items[index1];
            this.data.items[index1] = this.data.items[index2];
            this.data.items[index2] = tmp;
            this.current_elem = &this.data.items[index2];
            return this.updateAnim();
        }

        pub fn compareData(this: *This, x: T, y: T) i32 {
            this.comparison_count += 1;
            return if (x > y) 1 else if (x == y) 0 else -1;
        }

        pub fn updateAnim(this: This) bool {
            return UpdateScreen(T, this);
        }

        pub fn deinit(this: This) void {
            this.data.deinit();
        }
    };
}

fn UpdateScreen(comptime T: type, array: AnimatedArray(T)) bool {
    var color: raylib.Color = undefined;
    var height: c_int = raylib.GetScreenHeight();
    var width: c_int = @divTrunc(
        raylib.GetScreenWidth() - 100,
        @as(c_int, @intCast(array.data.items.len)),
    );

    var i: usize = 0;
    var data_height: c_int = undefined;
    raylib.BeginDrawing();
    raylib.ClearBackground(raylib.BLACK);
    while (i < array.data.items.len) : (i += 1) {
        color = if (&array.data.items[i] == array.current_elem) raylib.BLUE else raylib.WHITE;
        data_height = height + @divFloor(
            (array.data.items[i] - 255) * height,
            255,
        );

        raylib.DrawRectangle(
            @as(c_int, @intCast(i)) + width * @as(c_int, @intCast(i)),
            height - data_height,
            width,
            data_height,
            color,
        );
    }
    raylib.DrawText(
        raylib.TextFormat("Array Accesses: %i", array.access_count),
        20,
        20,
        20,
        raylib.LIGHTGRAY,
    );
    raylib.DrawText(
        raylib.TextFormat("Comparisons: %i", array.comparison_count),
        60,
        60,
        20,
        raylib.LIGHTGRAY,
    );

    raylib.EndDrawing();

    if (raylib.WindowShouldClose()) {
        return false;
    }

    std.time.sleep(50000000);
    return true;
}
