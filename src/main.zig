const std = @import("std");
const gtk = @import("gtk.zig");

fn print_list(list: ?*gtk.GList) void {
    var cur = list;
    while (cur) |node| {
        std.debug.print("{s}\n", .{@ptrCast([*:0]u8, node.*.data)});
        cur = @ptrCast(?*gtk.GList, node.*.next);
    }
}

pub fn main() anyerror!void {
    var app = gtk.gtk_application_new("com.github.carpenecopinum.traymagic", .G_APPLICATION_FLAGS_NONE);
    defer gtk.g_object_unref(app);

    gtk.gtk_init(null,null);    

    var theme = gtk.gtk_icon_theme_get_default();
    var iconlist  = gtk.gtk_icon_theme_list_icons(theme, null);
    print_list(iconlist);

    var indicator = gtk.app_indicator_new("example-simple-client",
        "face-pirate",   
        .APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
    gtk.app_indicator_set_status(indicator, .APP_INDICATOR_STATUS_ACTIVE);

    gtk.gtk_main();
}
