usingnamespace  @cImport({
    @cInclude("gtk/gtk.h");
    @cInclude("libappindicator/app-indicator.h");
});

pub fn g_signal_connect_1(instance: gpointer, detailed_signal: [*c]const gchar, c_handler: GCallback, data: gpointer) gulong {
    var zero: u32 = 0;
    const flags: *GConnectFlags = @ptrCast(*GConnectFlags, &zero);
    return g_signal_connect_data(instance, detailed_signal, c_handler, null, null, flags.*);
}