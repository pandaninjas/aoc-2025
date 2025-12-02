const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().createFile(
        "input.txt",
        .{ .read = true, .truncate = false },
    );
    defer file.close();

    var file_buffer: [1024]u8 = undefined;
    var fr = file.reader(&file_buffer);
    const reader = &fr.interface;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    var current: i32 = 50;
    var count: u32 = 0;

    read_loop: while (true) {
        if (reader.takeDelimiter('\n')) |line_r| {
            if (line_r == null) {
                break;
            }
            const line = line_r.?;
            if (line.len < 2) {
                break;
            }

            const is_left = line[0] == 'L';

            const slc = line[1..];

            const num = try std.fmt.parseInt(i32, slc, 10);

            if (is_left) {
                current -= num;
            } else {
                current += num;
            }

            if (@mod(current, 100) == 0) {
                count += 1;
            }
        } else |err| switch (err) {
            error.ReadFailed => {
                break :read_loop;
            },
            error.StreamTooLong => {
                break :read_loop;
            },
        }
    }
    try stdout.print("{any}\n", .{count});
    try stdout.flush();
}
