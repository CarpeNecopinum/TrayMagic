const std = @import("std");
const gtk = @import("gtk.zig");

pub fn main() anyerror!void {
    var app = gtk.gtk_application_new("com.github.carpenecopinum.traymagic", .G_APPLICATION_FLAGS_NONE);
    defer gtk.g_object_unref(app);


    gtk.gtk_init(null,null);    

    var indicator = gtk.app_indicator_new("example-simple-client",
        "/usr/share/icons/breeze/preferences/32/preferences-desktop-tablet.svg", 
        .APP_INDICATOR_CATEGORY_APPLICATION_STATUS);
    gtk.app_indicator_set_status(indicator, .APP_INDICATOR_STATUS_ACTIVE);

    gtk.gtk_main();
}
