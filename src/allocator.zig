//! Wrapper for zig memory allocator.

pub const VulkanMemoryAllocator = struct {
    handle: c.Allocator,

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
};

const vk = @import("vulkan");
const c = @import("./c.zig");
