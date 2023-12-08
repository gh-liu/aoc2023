const std = @import("std");

const day1 = @import("./day1.zig");
const day2 = @import("./day2.zig");
const day3 = @import("./day3.zig");
const day4 = @import("./day4.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try day1.run(allocator);
    std.debug.print("\n", .{});
    try day2.run(allocator);
    std.debug.print("\n", .{});
    try day3.run(allocator);
    std.debug.print("\n", .{});
    try day4.run(allocator);
}
