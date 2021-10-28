const std = @import("std");
const c = @import("gtk.zig");

const MagicPtr = *opaque{};

fn get_vtable(comptime structure: type, comptime t: type) *structure {
    const static = struct {
        var result = comptime {
            var res: structure = undefined;
            inline for (@typeInfo(structure).Struct.fields) |field| {
                const implementation = @field(t, field.name);

                // Check that the implementation fits the interface (roughly)
                const impl_info = @typeInfo(@TypeOf(implementation));
                const interface_info = @typeInfo(field.field_type);
                if (impl_info == .Fn) {
                    for (interface_info.Fn.args[1..]) |arg, i| {
                        const other_arg = impl_info.Fn.args[i+1];
                        if ((arg.arg_type == null) and (other_arg.arg_type != null) or 
                            (arg.arg_type != null) and (other_arg.arg_type == null)) {
                                @compileError("Argument type mismatch for " ++ @typeName(t) ++ "." ++ field.name ++ std.fmt.comptimePrint("#{}", .{i}));
                        } else if (arg.arg_type != null and other_arg.arg_type != null) {
                            if (arg.arg_type.? != other_arg.arg_type.?) {
                                @compileError("Argument type mismatch for " ++ @typeName(t) ++ "." ++ field.name ++ std.fmt.comptimePrint("#{}", .{i})
                                 ++ "(" ++ @typeName(arg.arg_type.?) ++ " vs " ++ @typeName(other_arg.arg_type.?) ++ ")");
                            }
                        }
                    }
                    if (impl_info.Fn.is_generic or interface_info.Fn.is_generic) {
                        @compileError("Generic functions not supported for " ++ @typeName(t) ++ "." ++ field.name);
                    }
                    if (impl_info.Fn.alignment != interface_info.Fn.alignment) {
                        @compileError("Alignment mismatch for " ++ @typeName(t) ++ "." ++ field.name);
                    }
                    if (impl_info.Fn.calling_convention != interface_info.Fn.calling_convention) {
                        @compileError("Calling convention mismatch for " ++ @typeName(t) ++ "." ++ field.name);
                    }
                    if ((impl_info.Fn.return_type == null) and (interface_info.Fn.return_type != null) or 
                        (impl_info.Fn.return_type != null) and (interface_info.Fn.return_type == null)) {
                            @compileError("Return type mismatch for " ++ @typeName(t) ++ "." ++ field.name);
                    } else if (impl_info.Fn.return_type != null and interface_info.Fn.return_type != null) {
                        if (impl_info.Fn.return_type.? != interface_info.Fn.return_type.?) {
                            @compileError("Return type mismatch for " ++ @typeName(t) ++ "." ++ field.name
                             ++ " (" ++ @typeName(impl_info.Fn.return_type.?) ++ " vs " ++ @typeName(interface_info.Fn.return_type.?) ++ ")");
                        }
                    }

                } else {
                    @compileError("Trying to implement " ++ field.name ++ " with a non-function");
                }

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