const std = @import("std");
const blz = @import("blz");

const Alloc = std.mem.Allocator;

const p = std.log.debug;

pub fn main(init: std.process.Init) !void {
    std.log.debug("hello from {s}", .{"main"});
    const a = init.gpa;

    try blz.circle.circleFun(a);
    //try listTest(a);
}

fn listTest(_: Alloc) !void {
    // const list = try blz.ds.List(u8).init(a);
    // defer list.deinit();

    // try list.append(42);
    // p("list[0] = {d}", .{list.get(0)});
}
