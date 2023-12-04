const std = @import("std");
const newFileLineIterator = @import("./root.zig").newFileLineIterator;

const print = std.debug.print;

pub fn run(allocator: std.mem.Allocator) !void {
    var grid = std.AutoHashMap(Postion, u8).init(allocator);
    defer grid.deinit();

    var iter = try newFileLineIterator("src/input/day3");
    var y: i32 = 0;
    var maxX: i32 = 0;
    var maxY: i32 = 0;
    while (try iter.next()) |line| {
        for (line, 0..) |c, x| {
            if (!isDot(c)) {
                try grid.putNoClobber(Postion{ .x = @intCast(x), .y = y }, c);
            }
            maxX = @intCast(x);
        }
        maxY = y;
        y += 1;
    }
    const max = Postion{ .x = maxX, .y = maxY };
    print("day3 part1: {d}\n", .{partNumbers(grid, max)});
    print("day2 part2: {d}\n", .{gearRatios(grid)});
}

inline fn isDot(c: u8) bool {
    return c == '.';
}

inline fn isStar(c: u8) bool {
    return c == '*';
}

const Postion = struct {
    x: i32,
    y: i32,
    fn move8(self: @This(), dir: Dir8) Postion {
        return Postion{ .x = self.x + dir.dx(), .y = self.y + dir.dy() };
    }
};

const Dir8 = enum(u3) {
    nw,
    n,
    ne,
    w,
    e,
    sw,
    s,
    se,
    fn dx(this: @This()) i32 {
        return switch (this) {
            .n => 0,
            .s => 0,
            .e => 1,
            .ne => 1,
            .se => 1,
            .w => -1,
            .nw => -1,
            .sw => -1,
        };
    }
    fn dy(this: @This()) i32 {
        return switch (this) {
            .w => 0,
            .e => 0,
            .n => 1,
            .nw => 1,
            .ne => 1,
            .s => -1,
            .sw => -1,
            .se => -1,
        };
    }
};
const Dir8s = [_]Dir8{ .nw, .n, .ne, .w, .e, .sw, .s, .se };

fn partNumbers(grid: std.AutoHashMap(Postion, u8), max: Postion) u32 {
    var total: u32 = 0;

    var curNum: u32 = 0;

    var isPartNum: bool = false;

    var y: i32 = -1;
    while (y < max.y + 1) : (y += 1) {
        var x: i32 = 0;
        while (x < max.x + 2) : (x += 1) {
            const pos = Postion{ .x = x, .y = y };
            const c = grid.get(pos) orelse '.';
            if (std.ascii.isDigit(c)) {
                curNum *= 10;
                curNum += (c - '0');

                // check if it's part number
                if (!isPartNum) {
                    var hasSymNeighbor = false;
                    for (Dir8s) |dir| {
                        if (grid.get(pos.move8(dir))) |n| {
                            if (!std.ascii.isDigit(n)) {
                                hasSymNeighbor = true;
                            }
                        }
                    }
                    isPartNum = isPartNum or hasSymNeighbor;
                }
            } else {
                if (curNum > 0) {
                    // std.debug.print("{}\n", .{curNum});
                    if (isPartNum) {
                        isPartNum = false;
                        total += curNum;
                    }
                    curNum = 0;
                }
            }
        }
    }
    return total;
}

fn findNumOfStar(grid: std.AutoHashMap(Postion, u8), pos: Postion) Postion {
    var x = pos.x;
    const y = pos.y;
    while (true) {
        const c = grid.get(Postion{ .x = x, .y = y }) orelse '.';
        if (!std.ascii.isDigit(c)) {
            return Postion{ .x = x + 1, .y = y };
        }
        x -= 1;
    }
}

fn getNum(grid: std.AutoHashMap(Postion, u8), pos: Postion) u32 {
    var num: u32 = 0;
    var x = pos.x;
    const y = pos.y;
    while (true) {
        const c = grid.get(Postion{ .x = x, .y = y }) orelse '.';
        if (!std.ascii.isDigit(c)) {
            return num;
        } else {
            num *= 10;
            num += (c - '0');
        }
        x += 1;
    }
}

fn gearRatios(grid: std.AutoHashMap(Postion, u8)) u32 {
    var sum: u32 = 0;

    var it = grid.iterator();
    while (it.next()) |entry| {
        if (!isStar(entry.value_ptr.*)) {
            continue;
        }
        const pos = entry.key_ptr.*;
        // std.debug.print("{any} {c}\n", .{ pos, entry.value_ptr });
        var gearRatio: u32 = 1;
        var nums: [8]u32 = undefined;
        var numNeighbors: usize = 0;
        for (Dir8s, 0..) |dir, i| {
            const n = pos.move8(dir);
            if (grid.get(n)) |nv| {
                if (std.ascii.isDigit(nv)) {
                    const num = getNum(grid, findNumOfStar(grid, n));
                    // std.debug.print("{}\n", .{num});
                    if (contain(nums, num)) {
                        nums[i] = 0;
                    } else {
                        nums[i] = num;
                        numNeighbors += 1;
                        gearRatio *= num;
                    }
                }
            }
        }
        if (numNeighbors == 2) {
            sum += gearRatio;
        }
    }

    return sum;
}

fn contain(nums: [8]u32, num: u32) bool {
    for (nums) |v| {
        if (v == num) {
            return true;
        }
    }
    return false;
}
