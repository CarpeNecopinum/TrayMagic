# TrayMagic
A custom tray icon to run commands and stuff

## Vision

Add a lightweight way to to run often-run commands via a tray icon (to integrate with minimal DEs like i3).

## Configuration

The configuration is done in the source code, so changing the configuration requires rebuilding the tool.

The things that the tool can do are represented as "Magics", the list of which the tool will use is configured inside `magics.zig`.
There are some predefined Magics, but you can also create your own.

### Included Magics:

**SingleCommandMagic:**

Runs a shell command when clicked on.

**InterruptibleCommandMagic:**

Displays a checkbox that starts a shell command when checked and sends a `SIGINT`to stop the command when unchecked.

**SubmenuMagic:**

Takes an array of other magics and displays them as a submenu.

## Case-Study: Fat-Pointer type erasure

In contrast to how most of the rest of the Zig-world provides run-time polymorphism (like `std.mem.Allocator`), the "Magics" in this tool are used via a fat-pointer based type erasure scheme, akin to how Rust trait objects or Go interface objects work.

The magics have to conform to an interface outlined in the `MagicSkeleton` type of `magic_trait.zig`.
There is no need to explicitly generate a method-pointer struct as member inside of each magic, however.
Instead the `get_vtable` function is used to extract the necessary interface functions and store them in a single static struct.

The `MagicTrait` takes care of the lookup inside the vtable and correct calling of the methods.

**Advantages:**

- for each implementation of the interface, there is just a single vtable instance 
    - (with `std.mem.Allocator` there will be an instance of the `Allocator` struct for every single instance of an allocator implementation)
    - thus the implementing structs will be smaller
    - fewer things to keep in cache

**Caveats:**

- we can't generate the `MagicTrait` via metaprogramming (due to `https://github.com/ziglang/zig/issues/6709`) yet, so the resulting code isn't perfectly DRY
- since the function pointers in the vtable share the same type for all implementing classes, there is some janky `@ptrCast`ing going on (as the type in the interface and the type in the implementation disagree about the type of `self`); there are however some checks in `get_vtable` to prevent the most worst footguns I've run into yet 
- definitely not worth the hassle for something as simple as this project, but nice to play around with

## State

Right now this is mostly me getting my feet wet with Zig.
It is relatively usable already.
However basically anything about this tool might change at any time, so don't rely on it too hard.
