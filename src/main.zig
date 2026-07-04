const std = @import("std");
const Io = std.Io;

const blz = @import("blz");

pub fn main(init: std.process.Init) !void {
    _ = init;
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.log.debug("All your {s} are belong to us.", .{"codebase"});
}

test "simple test" {
    const al = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(al); // Try commenting this out and see if zig detects the memory leak!
    try list.append(al, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
