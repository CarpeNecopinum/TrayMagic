const std = @import("std");
const c = @import("gtk.zig");
const MagicTrait = @import("magic_trait.zig").MagicTrait;

// const HelloMagic = struct {
//     x: u64 = 0, // make it a non-zero-bits type
//     magic = Magic{
//         .addToMenu = addToMenu
//     }

//     fn init(allocator: *std.mem.Allocator) !*HelloMagic {
//         var result = try allocator.create(HelloMagic);
//         result.* = HelloMagic{};
//         return result;
//     }

//     fn hello(item: ?*c.GtkWidget, user_data: ?*c_void) void {
//         std.debug.print("Hello World!\n", .{});
//     }

//     pub fn addToMenu(self: @This(), menu: *c.GtkMenu) void {
//         var item = c.gtk_image_menu_item_new_with_label("Hello World!");
//         c.gtk_menu_shell_insert(@ptrCast(*c.GtkMenuShell, menu), item, 1);
//         c.gtk_widget_show(item);
//         _ = c.g_signal_connect_1(item, "activate", @ptrCast(c.GCallback, HelloMagic.hello), null);
//     }
// };

const SingleCommandMagic = struct {
    allocator: *std.mem.Allocator,
    title: [:0]const u8 = "<Unnamed Command>",
    command: [*:0]const u8 = "true",

    fn init(allocator: *std.mem.Allocator, title: [:0]const u8, command: [*:0]const u8) !*SingleCommandMagic {
        var result = try allocator.create(SingleCommandMagic);
        result.* = SingleCommandMagic{
            .allocator = allocator,
            .title = title,
            .command = command
        };
        return result;
    }

    fn activate(self: *@This(), menu: *c.GtkMenu) callconv(.C) void {
        const cmd = std.fmt.allocPrintZ(self.allocator, "{s}", .{self.command}) catch return;
        var args: [3:null]? [*:0]const u8 = undefined;
        args[0] = "/usr/bin/bash";
        args[1] = "-c";
        args[2] = self.command;
        args[3] = null;

        const envptr = @ptrCast([*:null]const ?[*:0]const u8, std.os.environ.ptr);

        const pid = std.os.fork() catch return;
        if (pid == 0) {
            const err = std.os.execvpeZ(args[0].?, &args, envptr);
            return;
        }
    }

    pub fn addToMenu(self: *@This(), menu: *c.GtkMenu) void {
        var item = c.gtk_image_menu_item_new_with_label(self.title);
        c.gtk_menu_shell_insert(@ptrCast(*c.GtkMenuShell, menu), item, 1);
        c.gtk_widget_show(item);
        _ = c.g_signal_connect_swapped_1(
            item, 
            "activate", 
            @ptrCast(c.GCallback, @This().activate), 
            @ptrCast(*c_void, self)
            );
    }
};

const InterruptibleCommandMagic = struct {
    const Self = @This();
    allocator: *std.mem.Allocator,  
    title: [:0]const u8 = "<Unnamed Command>",
    command: [*:0]const u8 = "true",
    pid: std.os.pid_t = 0,

    fn init(allocator: *std.mem.Allocator, title: [:0]const u8, command: [*:0]const u8) !*Self {
        var result = try allocator.create(Self);
        result.* = Self{
            .allocator = allocator,
            .title = title,
            .command = command
        };
        return result;
    }

    fn toggled(self: *Self, item: *c.GtkCheckMenuItem) callconv(.C) void {
        const onoff = c.gtk_check_menu_item_get_active(item) != 0;
        if (onoff) {
            const cmd = std.fmt.allocPrintZ(self.allocator, "{s}", .{self.command}) catch return;
            var args: [3:null]? [*:0]const u8 = undefined;
            args[0] = "/usr/bin/bash";
            args[1] = "-c";
            args[2] = self.command;
            args[3] = null;

            const envptr = @ptrCast([*:null]const ?[*:0]const u8, std.os.environ.ptr);

            const pid = std.os.fork() catch return;
            if (pid == 0) {
                const err = std.os.execvpeZ(args[0].?, &args, envptr);
                return;
            } else {
                self.pid = pid;
            }
        } else {
            if (self.pid != 0) {
                 // SIGINT
                std.os.kill(self.pid, 2) catch |e| {
                    std.debug.print("Can't kill #{}: #{}", .{self.pid, e});
                };
            }
        }
    }

    pub fn addToMenu(self: *Self, menu: *c.GtkMenu) void {
        std.debug.print("Added checkbable\n", .{});
        var item = c.gtk_check_menu_item_new_with_label(self.title);
        c.gtk_menu_shell_insert(@ptrCast(*c.GtkMenuShell, menu), item, 1);
        c.gtk_widget_show(item);
        _ = c.g_signal_connect_swapped_1(
            item, 
            "toggled", 
            @ptrCast(c.GCallback, Self.toggled), 
            @ptrCast(*c_void, self)
            );
    }
};

pub fn buildMagics(allocator: *std.mem.Allocator) ![]MagicTrait {
    var magics = try allocator.alloc(MagicTrait, 2);
    //magics[0] = MagicTrait.create(try HelloMagic.init(allocator));
    magics[0] = MagicTrait.create(try SingleCommandMagic.init(allocator, "Hello (Command)", "echo 'Hello World'"));
    magics[1] = MagicTrait.create(try InterruptibleCommandMagic.init(allocator, "Hello (Checkable)", "watch echo 'Hello World'"));

    return magics;
}