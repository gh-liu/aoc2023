const std = @import("std");

const newFileLineIterator = @import("./root.zig").newFileLineIterator;

const print = std.debug.print;

const Card = struct {
    nums: std.ArrayList(u8) = undefined,
    winningNums: std.ArrayList(u8) = undefined,
    map: std.AutoHashMap(u8, bool) = undefined,

    const Self = @This();

    fn init(self: *Self, a: std.mem.Allocator) *Self {
        self.nums = std.ArrayList(u8).init(a);
        self.winningNums = std.ArrayList(u8).init(a);
        self.map = std.AutoHashMap(u8, bool).init(a);
        return self;
    }

    fn Parse(self: *Self, line: []const u8) !void {
        var it = std.mem.split(u8, line, ":");
        _ = it.next().?;

        const numbers = it.next().?;
        var numbersIt = std.mem.split(u8, numbers, "|");

        const winningNums = numbersIt.next().?;
        const nums = numbersIt.next().?;

        var winningNum: u8 = 0;
        // std.debug.print("{s}\n", .{winningNums});
        for (winningNums, 0..) |val, i| {
            if (std.ascii.isDigit(val)) {
                winningNum *= 10;
                winningNum += (val - '0');
                if (i < nums.len - 1) {
                    continue;
                }
            }
            if (winningNum > 0) {
                try self.winningNums.append(winningNum);
                // std.debug.print("{}..", .{winningNum});
                winningNum = 0;
            }
        }
        // std.debug.print("\n", .{});
        var number: u8 = 0;
        // std.debug.print("{s}\n", .{nums});
        for (nums, 0..) |val, i| {
            if (std.ascii.isDigit(val)) {
                number *= 10;
                number += (val - '0');
                if (i < nums.len - 1) {
                    continue;
                }
            }
            if (number > 0) {
                try self.nums.append(number);
                // std.debug.print("{}..", .{number});
                number = 0;
            }
        }
    }

    fn points(self: *Self) !u32 {
        for (self.nums.items) |value| {
            try self.map.put(value, true);
        }
        var p: u32 = 0;
        for (self.winningNums.items) |value| {
            if (self.map.get(value)) |_| {
                p += 1;
            }
        }
        return p;
    }

    fn deinit(self: *Self) void {
        self.nums.deinit();
        self.winningNums.deinit();
        self.map.deinit();
    }
};

fn pointsForMatches(matches: u32) u32 {
    if (matches == 0) {
        return 0;
    }
    return @as(u32, 1) << @intCast(matches - 1);
}

pub fn run(allocator: std.mem.Allocator) !void {
    const a = allocator;

    var copiesBuf: [256]u32 = undefined;
    @memset(copiesBuf[0..], 1);
    var copies: []u32 = copiesBuf[0..];

    var iter = try newFileLineIterator("src/input/day4");
    var sum1: u32 = 0;
    var sum2: u32 = 0;
    while (try iter.next()) |line| {
        var card = Card{};
        defer card.deinit();
        _ = try card.init(a).Parse(line);

        const matches = try card.points();
        sum1 += pointsForMatches(matches);

        const numTimes = copies[0];
        copies = copies[1..];
        sum2 += numTimes;
        var i: u32 = 0;
        while (i < matches) : (i += 1) {
            copies[i] += numTimes;
        }
    }
    print("day4 part1: {d}\n", .{sum1});
    print("day4 part2: {d}\n", .{sum2});
}

test "Parse Card" {
    const a = std.testing.allocator;
    const line = "Card   1: 61 73 92 28 96 76 32 62 44 53 | 61 17 26 13 92  5 73 29 53 42 62 46 96 32 21 97 99 28 12  4  7 44 19 71 76";
    var card = Card{};
    defer card.deinit();
    try card.init(a).Parse(line);
    var b = std.ArrayList(u8).init(a);
    defer b.deinit();
    try b.append(61);
    try b.append(73);
    try b.append(92);
    try b.append(28);
    try b.append(96);
    try b.append(76);
    try b.append(32);
    try b.append(62);
    try b.append(44);
    try b.append(53);
    try std.testing.expect(arrayListEquals(card.winningNums, b));
}

fn arrayListEquals(a: std.ArrayList(u8), b: std.ArrayList(u8)) bool {
    // check if len are equal
    if (a.items.len != b.items.len) {
        return false;
    }

    // compare element one by one
    var i: usize = 0;
    while (i < a.items.len) : (i += 1) {
        if (a.items[i] != b.items[i]) {
            return false;
        }
    }

    return true;
}
