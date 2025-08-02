const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var module = b.addModule("zig_vma", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
        .link_libcpp = true,
    });

    // ------------------------------------------------------------------------
    // START: Vulkan memory allocator
    // ------------------------------------------------------------------------
    const dep = b.dependency("VulkanMemoryAllocator", .{});

    const include_path = dep.path("include");
    module.addIncludePath(include_path);

    // Generate implementation
    module.addCSourceFile(.{
        .file = b.addWriteFiles().add("vma.cc",
            \\#define VMA_IMPLEMENTATION
            \\#define VMA_STATIC_VULKAN_FUNCTIONS 0
            \\#include <vk_mem_alloc.h>
        ),

        .flags = &.{"-std=c++17"},
    });
    // ------------------------------------------------------------------------
    // END: Vulkan memory allocator
    // ------------------------------------------------------------------------

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const module_unit_tests = b.addTest(.{
        .root_module = module,
    });

    const run_module_unit_tests = b.addRunArtifact(module_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_module_unit_tests.step);
}
