const std = @import("std");
const newFileLineIterator = @import("./root.zig").newFileLineIterator;

const print = std.debug.print;

const CubeSet = struct {
    red: u8 = 0,
    green: u8 = 0,
    blue: u8 = 0,
};

const Game = struct {
    gameID: u8 = undefined,
    cubeSets: std.ArrayList(CubeSet) = undefined,

    const Self = @This();

    fn init(slef: *Self, a: std.mem.Allocator) *Self {
        slef.gameID = 0;
        slef.cubeSets = std.ArrayList(CubeSet).init(a);
        return slef;
    }

    fn parse(slef: *Self, line: []const u8) !void {
        var it = std.mem.split(u8, line, ":");

        var game = std.mem.split(u8, it.next().?, " ");
        _ = game.next();
        slef.gameID = try std.fmt.parseInt(u8, game.next().?, 10);

        var sets = std.mem.split(u8, it.next().?, ";");
        while (sets.next()) |set| {
            var item = std.mem.split(u8, set, ",");
            var cubeSet = CubeSet{};
            while (item.next()) |cube| {
                var cubeandcount = std.mem.split(u8, std.mem.trim(u8, cube, " "), " ");
                const count = cubeandcount.next().?;
                const color = cubeandcount.next().?;
                if (strEqual("red", color)) {
                    cubeSet.red = try std.fmt.parseInt(u8, count, 10);
                }
                if (strEqual("green", color)) {
                    cubeSet.green = try std.fmt.parseInt(u8, count, 10);
                }
                if (strEqual("blue", color)) {
                    cubeSet.blue = try std.fmt.parseInt(u8, count, 10);
                }
            }
            try slef.cubeSets.append(cubeSet);
        }
    }

    fn deinit(slef: *Self) void {
        return slef.cubeSets.deinit();
    }
};

fn part1(game: *Game) u8 {
    var gameMatch = true;
    for (game.cubeSets.items) |set| {
        const isMatch = match(set);
        gameMatch = gameMatch and isMatch;
    }

    if (gameMatch) {
        return game.gameID;
    }
    return 0;
}

fn part2(game: *Game) u64 {
    var miniRed: u32 = 0;
    var miniGreen: u32 = 0;
    var miniBlue: u32 = 0;
    for (game.cubeSets.items) |set| {
        if (set.red > miniRed) {
            miniRed = set.red;
        }
        if (set.green > miniGreen) {
            miniGreen = set.green;
        }
        if (set.blue > miniBlue) {
            miniBlue = set.blue;
        }
    }

    var res: u64 = undefined;
    res = miniRed * miniGreen;
    res = res * miniBlue;
    return res;
}

fn strEqual(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

const REDLIMIT = 12;
const GREENLIMIT = 13;
const BLUELIMIT = 14;

fn match(cubes: CubeSet) bool {
    return cubes.red <= REDLIMIT and cubes.green <= GREENLIMIT and cubes.blue <= BLUELIMIT;
}

pub fn run(allocator: std.mem.Allocator) !void {
    var iter = try newFileLineIterator("src/input/day2");
    var sum1: u32 = 0;
    var sum2: u64 = 0;
    while (try iter.next()) |line| {
        var game = Game{};
        try game.init(allocator).parse(line);
        defer game.deinit();
        sum1 += part1(&game);
        sum2 += part2(&game);
    }
    print("day2 part1: {d}\n", .{sum1});
    print("day2 part2: {d}\n", .{sum2});
}
