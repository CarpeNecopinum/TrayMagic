const std = @import("std");
usingnamespace @import("magics.zig");

pub fn buildMagics(allocator: *std.mem.Allocator) ![]MagicTrait {
    var magics = try allocator.alloc(MagicTrait, 3);
    magics[0] = MagicTrait.create(try SingleCommandMagic.init(allocator, "Hello (Command)", "echo 'Hello World'"));
    magics[1] = MagicTrait.create(try InterruptibleCommandMagic.init(allocator, "Hello (Checkable)", "watch echo 'Hello World'"));
    magics[2] = MagicTrait.create(try SubmenuMagic.init(allocator, "External Monitor", &.{
        MagicTrait.create(try SingleCommandMagic.init(allocator, "Clone", "monitor-on")),
        MagicTrait.create(try SingleCommandMagic.init(allocator, "Combine", "monitor-combine")),
        MagicTrait.create(try SingleCommandMagic.init(allocator, "Disable", "monitor-off"))
    }));

    return magics;
}