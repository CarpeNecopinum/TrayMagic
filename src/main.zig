const std = @import("std");
const gtk = @import("gtk.zig");

fn print_list(list: ?*gtk.GList) void {
    var cur = list;
    while (cur) |node| {
        std.debug.print("{s}\n", .{@ptrCast([*:0]u8, node.*.data)});
        cur = @ptrCast(?*gtk.GList, node.*.next);
    }
}

fn hello(item: ?*gtk.GtkWidget, user_data: ?*c_void) void {
    std.debug.print("Hello World!\n", .{});
}

pub fn main() anyerror!void {
    var app = gtk.gtk_application_new("com.github.carpenecopinum.traymagic", .G_APPLICATION_FLAGS_NONE);
    defer gtk.g_object_unref(app);

    gtk.gtk_init(null,null);    

    // var theme = gtk.gtk_icon_theme_get_default();
    // var iconlist  = gtk.gtk_icon_theme_list_icons(theme, null);
    // print_list(iconlist);

    var indicator = gtk.app_indicator_new("example-simple-client",
        "face-pirate",   
        .APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
    gtk.app_indicator_set_status(indicator, .APP_INDICATOR_STATUS_ACTIVE);

    var menu = gtk.gtk_menu_new();
    var item1 = gtk.gtk_image_menu_item_new_with_label("Hello World!");
    gtk.gtk_menu_shell_insert(@ptrCast(*gtk.GtkMenuShell, menu), item1, 1);
    gtk.gtk_widget_show(item1);


    _ = gtk.g_signal_connect_1(item1, "activate", @ptrCast(gtk.GCallback, hello), null);


    gtk.app_indicator_set_menu(indicator, @ptrCast(*gtk.GtkMenu, menu));

    gtk.gtk_main();
}
