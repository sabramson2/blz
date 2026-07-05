const std = @import("std");

const ds = @import("../ds.zig");
const List = ds.List;
const p = std.log.debug;
const a = std.testing.allocator;

test "list test 1" {
    // create the list
    const list = try List(u8).init(a);
    defer list.deinit(a);

    list.append(42);
    p("list[0] = ", .{list.get(0)});
}


fn l(m: []const u8) void {
    p("{s}", .{m});
}