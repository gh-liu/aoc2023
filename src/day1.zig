const std = @import("std");
const newFileLineIterator = @import("./root.zig").newFileLineIterator;

const print = std.debug.print;

fn calibration1(line: []const u8) u8 {
    var first: ?u8 = null;
    var last: ?u8 = null;
    for (line) |c| {
        var dig: u8 = 0;
        if (c >= '0' and c <= '9') {
            dig = c - '0';
        } else {
            continue;
        }
        if (first == null) {
            first = dig;
        }
        last = dig;
    }
    return first.? * 10 + last.?;
}

const NUMS = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn calibration2(line: []const u8) u8 {
    var first: ?u8 = null;
    var last: ?u8 = null;
    for (line, 0..) |c, i| {
        var dig: ?u8 = null;
        if (c >= '0' and c <= '9') {
            dig = c - '0';
        } else {
            for (NUMS, 1..) |numStr, d| {
                if (std.mem.startsWith(u8, line[i..], numStr)) {
                    dig = @intCast(d);
                }
            }
        }
        if (dig) |d| {
            _ = d;
            if (first == null) {
                first = dig;
            }
            last = dig;
        }
    }
    return first.? * 10 + last.?;
}

pub fn run(allocator: std.mem.Allocator) !void {
    _ = allocator;

    var iter = try newFileLineIterator("src/input/day1");
    var sum1: u32 = 0;
    var sum2: u32 = 0;
    while (try iter.next()) |line| {
        sum1 += calibration1(line);
        sum2 += calibration2(line);
    }
    print("day1 part1: {d}\n", .{sum1});
    print("day1 part2: {d}\n", .{sum2});
}
