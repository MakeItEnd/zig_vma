//! Wrapper for zig memory allocator.

pub const VulkanMemoryAllocator = struct {
    handle: c.Allocator,

    pub fn importVulkanFunctionsFromVolk(
        p_allocator_create_info: *const c.AllocationCreateInfo,
        p_dst_vulkan_functions: *c.VulkanFunctions,
    ) !void {
        const result = c.vmaImportVulkanFunctionsFromVolk(
            p_allocator_create_info,
            p_dst_vulkan_functions,
        );

        if (result != .success) {
            return error.FaildToBindVulkanFunctionsFromVolk;
        }
    }

    pub fn init(
        create_info: *const c.AllocatorCreateInfo,
    ) !VulkanMemoryAllocator {
        var handle: c.Allocator = .null_handle;

        const result = c.vmaCreateAllocator(
            create_info,
            &handle,
        );

        if (result != .success or handle == .null_handle) {
            return error.FaildToCreateAllocator;
        }

        return .{
            .handle = handle,
        };
    }

    pub fn deinit(self: VulkanMemoryAllocator) void {
        c.vmaDestroyAllocator(self.handle);
    }

    pub fn checkCorruption(
        self: VulkanMemoryAllocator,
        memory_type_bits: u32,
    ) vk.Result {
        return c.vmaCheckCorruption(
            self.handle,
            memory_type_bits,
        );
    }
};

const vk = @import("vulkan");
const c = @import("./c.zig");
