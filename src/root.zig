const std = @import("std");

const print = std.debug.print;

const BUFFERSIZE = 4096;
const ReaderType = std.fs.File.Reader;
const BufferedReaderType = std.io.BufferedReader(BUFFERSIZE, ReaderType);

const FileLineIterator = struct {
    file: std.fs.File,
    buf_reader: BufferedReaderType,
    stream: ?BufferedReaderType.Reader = null,
    buffer: [BUFFERSIZE]u8,

    const Self = @This();
    pub fn next(self: *Self) !?[]u8 {
        if (self.stream == null) {
            self.stream = self.buf_reader.reader();
        }
        if (self.stream) |stream| {
            return stream.readUntilDelimiterOrEof(&self.buffer, '\n');
        }
        unreachable;
    }

    pub fn deinit(self: *Self) void {
        self.file.close();
    }
};

pub fn newFileLineIterator(file: []const u8) !FileLineIterator {
    var f = try std.fs.cwd().openFile(file, .{});
    const buf_reader = std.io.bufferedReader(f.reader());

    return FileLineIterator{
        .file = f,
        .buf_reader = buf_reader,
        .buffer = undefined,
    };
}
