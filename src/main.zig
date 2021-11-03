const std = @import("std");
const gtk = @import("gtk.zig");

const buildOptions = @import("build_options");
const buildMagics = @import(buildOptions.magics_config).buildMagics;

pub const io_mode = .evented;

fn print_list(list: ?*gtk.GList) void {
    var cur = list;
    while (cur) |node| {
        std.debug.print("{s}\n", .{@ptrCast([*:0]u8, node.*.data)});
        cur = @ptrCast(?*gtk.GList, node.*.next);
    }
}

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = &gpa.allocator;

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

    const magics = try buildMagics(allocator);

    for (magics) |magic| {
        magic.addToMenu(@ptrCast(*gtk.GtkMenu, menu));
    }

    gtk.app_indicator_set_menu(indicator, @ptrCast(*gtk.GtkMenu, menu));
    gtk.gtk_main();
}
