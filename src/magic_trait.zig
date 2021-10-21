const std = @import("std");
const c = @import("gtk.zig");

const MagicPtr = *opaque{};

fn get_vtable(comptime structure: type, comptime t: type) *structure {
    const static = struct {
        var result = comptime {
            var res: structure = undefined;
            inline for (@typeInfo(structure).Struct.fields) |field| {
                const implementation = @field(t, field.name);
                const casted = @ptrCast(field.field_type, implementation);
                @field(res, field.name) = casted;
            }
            return res;
        };
    };

    return &static.result;
}

const MagicSkeleton = struct {
    addToMenu: fn(self: MagicPtr, menu: *c.GtkMenu) void
};

// We can do the vtable via metaprogramming, but not the trait methods yet :(
// waiting for https://github.com/ziglang/zig/issues/6709 ...
pub const MagicTrait = struct {
    vtable: *MagicSkeleton,
    data: MagicPtr,

    pub fn addToMenu(self: @This(), menu: *c.GtkMenu) void {
        self.vtable.addToMenu(self.data, menu);
    }

    pub fn create(magic_ptr: anytype) @This() {
        return MagicTrait{
            .vtable = get_vtable(MagicSkeleton, @TypeOf(magic_ptr.*)),
            .data = @ptrCast(MagicPtr, magic_ptr),
        };
    }
};