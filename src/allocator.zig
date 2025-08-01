//! Wrapper for zig memory allocator.

pub const Allocator = struct {
    handle: c.Allocator,
};

const c = @import("./c.zig");
