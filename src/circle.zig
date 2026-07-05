const std = @import("std");

const Alloc = std.mem.Allocator;
const p = std.log.debug;
const p2 = std.debug.print;

pub const CircleGen = struct {
    // map to hold pre-computed edges
    edges: std.AutoHashMap(u32, []u32),

    //pub fn gen() 
};

pub fn circleFun(al: Alloc) !void {
    const r = 30;
    const edges = try findCircleEdge(al, r);
    defer al.free(edges);

    for (edges) |edge| {
        p("{d}", .{edge});
    }

    for (0..(r * 2)) |y| {
        for (0..(r * 2)) |x| {
            const in_circle = inCircle(@intCast(x), @intCast(y), edges);
            const val = if (in_circle) "X" else " ";
            p2("{s}", .{val});
        }
        p2("\n", .{});
    }
}

fn findCircleEdge(al:Alloc, radius: u32) ![]u32 {
    var edges: []u32 = try al.alloc(u32, radius);

    // outer loop is top to bottom
    for (0..radius) |y| {
        // inner loop is left to right
        for (0..radius) |x| {
            const a = radius - x;
            const b = radius - y;
            const c: u32 = @intFromFloat(length(@intCast(a), @intCast(b)));
            if (c <= radius) {
                edges[y] = @intCast(x);
                p("y: {d} = {d}", .{y, c});
                break;
            }

            if (y == 0) {
                p("y:{d} x:{d} c:{d}", .{y, x, c});
            }
            if (x == (radius - 1)) {
                p("y: {d} - no c <= r?", .{y});
            }
        }
    }
    return edges;
}

// find the hypotenuse of the triangle
fn length(a: u32, b: u32) f32 {
    const fa = @as(f32, @floatFromInt(a));
    const fb = @as(f32, @floatFromInt(b));
    const c2 = (fa * fa) + (fb * fb);
    return @sqrt(c2);
}

fn inCircle(x: u32, y: u32, circle: []u32) bool {
    const radius = circle.len;
    const flip = (radius * 2) - 1;
    if (y < radius) {
        // top left
        if (x < radius) {
            return x >= circle[y];
        }
        // top right
        return x <= (flip - circle[y]);
    }
    // bottom left
    if (x < radius) {
        return x >= circle[flip - y];
    }
    // bottom right
    return x <= (flip - circle[flip - y]);
}