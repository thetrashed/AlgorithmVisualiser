const std = @import("std");
const raylib = @import("raylib.zig");
const array = @import("customArray.zig");
const sorting = @import("sorting.zig");

const animatedIntArray = array.AnimatedArray(c_int);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);

    const allocator = gpa.allocator();

    const seed: u64 = 100;
    var prng = std.rand.DefaultPrng.init(seed);

    var list = animatedIntArray.init(allocator);
    defer list.deinit();
    for (0..300) |_| {
        try list.data.append(@as(c_int, prng.random().int(u8)));
    }

    std.debug.print("{any}\n\n", .{list});

    raylib.SetConfigFlags(raylib.FLAG_WINDOW_RESIZABLE);
    raylib.InitWindow(800, 600, "Raylib Example");
    defer raylib.CloseWindow();

    std.debug.print("{any}\n", .{list});
    try sorting.mergeSort(c_int, &list, 0, list.data.items.len);
    std.debug.print("{any}\n", .{list});
    std.time.sleep(2000000000);
}
