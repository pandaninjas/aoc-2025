const std = @import("std");
const day_2 = @import("day_2");

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

    const line_r = try reader.takeDelimiter('\n');
    const line = line_r.?;

    var it = std.mem.splitAny(u8, line, ",");

    var sums_p1: u64 = 0;
    var sums_p2: u64 = 0;

    while (true) {
        const part_r = it.next();
        if (part_r == null) {
            break;
        }
        const part = part_r.?;
        var parts = std.mem.splitAny(u8, part, "-");
        const start: u64 = try std.fmt.parseInt(u64, parts.next().?, 10);
        const until: u64 = try std.fmt.parseInt(u64, parts.next().?, 10);
        var i = start;
        i_runner: while (i <= until) : (i += 1) {
            const log10 = std.math.log10(i);
            if (log10 % 2 != 0) { // even logs correspond to odd number of digits
                // if a number is something twice, it divides (10 ** ceil(log10 / 2)) + 1, i.e. 11, 101, 1001
                // log10(11) = 1.something, it divides 11
                // log10(1111) = 3.something, it divides 101
                const divides = std.math.pow(u64, 10, @divFloor(log10, 2) + 1) + 1;
                if (i % divides == 0) {
                    sums_p1 += i;
                }
            }

            const num_digits = log10 + 1;
            // find all n >= 2 such that n | num_digits, then split the string representation into n parts
            var n: u64 = 2;

            // largest u64 has length 20
            var str_buf: [20]u8 = undefined;
            const str_repr = try std.fmt.bufPrint(&str_buf, "{d}", .{i});

            n_checker: while (n <= num_digits) : (n += 1) {
                if (@mod(num_digits, n) != 0) {
                    continue; // cannot be
                }
                const size = @divExact(num_digits, n);
                var n_it = std.mem.window(u8, str_repr[0..num_digits], size, size);
                const to_cmp = n_it.next().?; // extract first one, we are guaranteed to have it
                while (true) {
                    const npart_r = n_it.next();
                    if (npart_r == null) {
                        break;
                    }
                    const npart = npart_r.?;
                    if (!std.mem.eql(u8, to_cmp, npart)) {
                        continue :n_checker;
                    }
                }
                sums_p2 += i;
                continue :i_runner;
            }
        }
    }
    try stdout.print("result1: {any}, result2: {any}", .{ sums_p1, sums_p2 });
    try stdout.flush();
}
