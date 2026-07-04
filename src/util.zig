const std = @import("std");

const Alloc = std.mem.Allocator;
const Io = std.Io;

const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

pub const Rand = struct {
    engine: std.Random.Xoshiro256,

    pub fn init(io: std.Io) Rand {
        const seed_time = @as(u64, @intCast(std.Io.Clock.awake.now(io).toMilliseconds()));
        return .{
            .engine = std.Random.Xoshiro256.init(seed_time),
        };
    }

    pub fn randInt(self: *Rand, max: u32) u32 {
        return self.engine.random().intRangeLessThan(u32, 0, max);
    }

    pub fn rand(self: *Rand) std.Random {
        return self.engine.random();
    }

    // caller must free the returned slice themselves
    // a-zA-Z0-9
    pub fn randStr(self: *Rand, a: Alloc, size: u64) ![]u8 {
        var chars = try a.alloc(u8, size);
        for (0..size) |i| {
            const index: u8 = @intCast(self.randInt(charset.len));
            chars[i] = charset[index];
        }
        return chars;
    }
};

pub const Timer = struct {
    cycles_per_print: u32,
    cycles: u64 = 0,
    total_time: u64 = 0,
    time_start: std.Io.Timestamp = undefined,
    avg_nanos_per_cycle: f64 = 0.0,

    pub fn init(cycles_per_print: u32) Timer {
        return Timer {
            .cycles_per_print = cycles_per_print,
        };
    }

    pub fn start(self: *Timer, io: Io) void {
        self.time_start = std.Io.Clock.real.now(io);
    }

    pub fn end(self: *Timer, io: Io) void {
        const time_elapsed = self.time_start.untilNow(io, .real);
        const nanos_elapsed: u64 = @intCast(time_elapsed.toNanoseconds());
        self.cycles += 1;
        self.total_time += nanos_elapsed;

        const total_time_float = @as(f64, @floatFromInt(self.total_time));
        const cycles_float     = @as(f64, @floatFromInt(self.cycles));

        self.avg_nanos_per_cycle = total_time_float / cycles_float;

        if (self.cycles % self.cycles_per_print == 0) {
            std.debug.print("{d} {d:.2} {d}\n", .{self.cycles, self.avg_nanos_per_cycle, self.total_time});
        }
    }
};
