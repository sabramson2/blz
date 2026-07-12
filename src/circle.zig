const std = @import("std");

const Alloc = std.mem.Allocator;
const p = std.log.debug;
const p2 = std.debug.print;

pub const Circle = struct {
    // these are owned by the CircleGen that created it
    // since we cache them per radius value
    edges: []u32,

    pub fn init(edges: []u32) Circle {
        return .{.edges = edges};
    }

    pub fn deinit(s: *Circle, a: Alloc) void {
        a.free(s.edges);
    }

    pub fn inCircle(s: *Circle, x: u32, y: u32) bool {
        const circle = s.edges;
        const radius = circle.len;
        const flip = (radius * 2) - 1;
        if (y < radius) {
            // top left quadrant
            if (x < radius) {
                return x >= circle[y];
            }
            // top right quadrant
            return x <= (flip - circle[y]);
        }
        // bottom left quadrant
        if (x < radius) {
            return x >= circle[flip - y];
        }
        // bottom right quadrant
        return x <= (flip - circle[flip - y]);
    }
};

pub const CircleGen = struct {
    // map to hold pre-computed edges
    circle_cache: std.AutoHashMap(u32, Circle),

    pub fn init(a: Alloc) !CircleGen {
        return .{
            .circle_cache = std.AutoHashMap(u32, Circle).init(a)
        };
    }

    pub fn deinit(s: *CircleGen, a: Alloc) void {
        var iter = s.circle_cache.iterator();
        while (iter.next()) |item| { item.value_ptr.deinit(a); }
        s.circle_cache.deinit();
    }

    pub fn gen(s: *CircleGen, a: Alloc, radius: u32) !*Circle {
        const circle = try s.circle_cache.getOrPut(radius);
        if (circle.found_existing) {
            return circle.value_ptr;
        }
        const edges = try findCircleEdge(a, radius);
        circle.value_ptr.* = Circle.init(edges);
        return circle.value_ptr;
    }
};

pub fn circleFun(a: Alloc) !void {
    const circleGen = try a.create(CircleGen);
    defer {
        circleGen.deinit(a);
        a.destroy(circleGen);
    }
    circleGen.* = try CircleGen.init(a);

    const radius_list = [_]u32{3, 3, 5, 5, 10, 10};
    for (radius_list) |radius| {
        const edges = try circleGen.gen(a, radius);
        drawCircle(edges);
    }

    p("map size = {d}",  .{circleGen.circle_cache.count()});
}

fn drawCircle(circle: *Circle) void {
    const edges = circle.edges;
    const radius: u32 = @intCast(edges.len);
    for (0..(radius * 2)) |y| {
        for (0..(radius * 2)) |x| {
            const in_circle = circle.inCircle(@intCast(x), @intCast(y));
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
                //p("y: {d} = {d}", .{y, c});
                break;
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

// fn inCircle(x: u32, y: u32, circle: []u32) bool {
//     const radius = circle.len;
//     const flip = (radius * 2) - 1;
//     if (y < radius) {
//         // top left
//         if (x < radius) {
//             return x >= circle[y];
//         }
//         // top right
//         return x <= (flip - circle[y]);
//     }
//     // bottom left
//     if (x < radius) {
//         return x >= circle[flip - y];
//     }
//     // bottom right
//     return x <= (flip - circle[flip - y]);
// }