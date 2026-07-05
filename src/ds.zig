const std = @import("std");

const Alloc = std.mem.Allocator;

// generics!
// my own custom List
// pub fn List(comptime T: type) type {
//     return struct {
//         list: std.ArrayList(T),
//         alloc: Alloc,

//         const Self = @This();

//         pub fn init(a: Alloc) !*Self {
//             const list = std.ArrayList(T).empty;
//             const x = try a.create(Self);
//             x.* = .{.list = list, .alloc = a};
//             return x;
//         }

//         pub fn deinit(self: *Self) void {
//             // need to get pointers when iterating, or you operate on returned copy
//             for (self.list.items) |*item| {
//                 item.deinit(self.alloc);
//             }
//             self.list.deinit(self.alloc);
//             self.alloc.destroy(self);
//         }

//         pub fn append(self: *Self, item: T) !void {
//             try self.list.append(self.alloc, item);
//         }

//         pub fn remove(self: *Self, index: usize) void {
//             self.list.items[index].deinit(self.alloc);
//             _ = self.list.orderedRemove(index);
//         }

//         pub fn get(self: *Self, index: usize) *T {
//             return &self.list.items[index];
//         }

//         pub fn getCopy(self: *Self, index: usize) T {
//             return self.list.items[index];
//         }

//         pub fn len(self: *Self) usize {
//             return self.list.items.len;
//         }

//     };
// }
