const std = @import("std");
const c = @import("gtk.zig");
const MagicTrait = @import("magic_trait.zig").MagicTrait;

const HelloMagic = struct {
    x: u64 = 0, // make it a non-zero-bits type

    fn hello(item: ?*c.GtkWidget, user_data: ?*c_void) void {
        std.debug.print("Hello World!\n", .{});
    }

    pub fn addToMenu(self: @This(), menu: *c.GtkMenu) void {
        var item = c.gtk_image_menu_item_new_with_label("Hello World!");
        c.gtk_menu_shell_insert(@ptrCast(*c.GtkMenuShell, menu), item, 1);
        c.gtk_widget_show(item);
        _ = c.g_signal_connect_1(item, "activate", @ptrCast(c.GCallback, HelloMagic.hello), null);
    }
};
var hello_magic = HelloMagic{};


pub const magics = [_]MagicTrait{
    MagicTrait.create(&hello_magic),
};