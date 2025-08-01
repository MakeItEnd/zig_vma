const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zw_vma",
        .root_module = lib_mod,
    });

    // ------------------------------------------------------------------------
    // START: Vulkan memory allocator
    // ------------------------------------------------------------------------
    lib.linkLibCpp(); // VMA is a CPP library.

    const dep = b.dependency("VulkanMemoryAllocator", .{});
    const include_path = dep.path("include");

    // Generate implementation
    const impl = try std.fs.createFileAbsolute(
        try dep.path("vma.cc").getPath3(
            b,
            &lib.step,
        ).toString(b.allocator),
        .{},
    );
    try impl.writeAll(
        \\#define VMA_IMPLEMENTATION
        \\#define VMA_STATIC_VULKAN_FUNCTIONS 0
        \\#include <vk_mem_alloc.h>
    );
    impl.close();

    lib.addCSourceFile(.{
        .file = dep.path("vma.cc"),
        .flags = &.{"-std=c++17"},
    });
    lib.addIncludePath(include_path);
    // ------------------------------------------------------------------------
    // END: Vulkan memory allocator
    // ------------------------------------------------------------------------

    b.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_module = lib_mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
