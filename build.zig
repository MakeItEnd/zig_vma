const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep = b.dependency("VulkanMemoryAllocator", .{});
    const mod = b.addModule("zig_vma", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });
    mod.addIncludePath(dep.path("include"));
    mod.addCSourceFile(.{
        .file = b.addWriteFiles().add("vma.cc",
            \\#define VMA_IMPLEMENTATION
            \\#define VMA_STATIC_VULKAN_FUNCTIONS 0
            \\#include <vk_mem_alloc.h>
        ),
        .flags = &.{"-std=c++17"},
    });

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
