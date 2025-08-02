//! As an extra feature, the core allocation algorithm of the library is exposed
//! through a simple and convenient API of "virtual allocator". It doesn't allocate
//! any real GPU memory. It just keeps track of used and free regions of a
//! "virtual block". You can use it to allocate your own memory or other
//! objects, even completely unrelated to Vulkan. A common use case is
//! sub-allocation of pieces of one large GPU buffer.

pub const VirtualBlock = struct {
    handle: c.VirtualBlock,

    /// Creates new VmaVirtualBlock object.
    pub fn init(
        create_info: *const c.VirtualBlockCreateInfo,
    ) !c.VirtualBlock {
        var virtual_block: c.VirtualBlock = .null_handle;

        const result = c.vmaCreateVirtualBlock(
            create_info,
            &virtual_block,
        );

        if (result != .success or virtual_block == .null_handle) {
            return error.FaildToCreateVirtualBlock;
        }

        return VirtualBlock{
            .handle = virtual_block,
        };
    }

    /// Destroys VmaVirtualBlock object.
    ///
    /// Please note that you should consciously handle virtual allocations that could remain unfreed in the block. You should either free them individually using vmaVirtualFree() or call vmaClearVirtualBlock() if you are sure this is what you want. If you do neither, an assert is called.
    ///
    /// If you keep pointers to some additional metadata associated with your virtual allocations in their pUserData, don't forget to free them.
    pub fn deinit(
        self: VirtualBlock,
    ) void {
        c.vmaDestroyVirtualBlock(self.handle);
    }

    /// Allocates new virtual allocation inside given VmaVirtualBlock.
    ///
    /// If the allocation fails due to not enough free space available, VK_ERROR_OUT_OF_DEVICE_MEMORY is returned (despite the function doesn't ever allocate actual GPU memory). pAllocation is then set to VK_NULL_HANDLE and pOffset, if not null, it set to UINT64_MAX.
    pub fn allocate(
        self: *VirtualBlock,
        create_info: *const c.VirtualAllocationCreateInfo,
        offset: ?*vk.DeviceSize,
    ) !c.VirtualAllocation {
        var allocation: c.VirtualAllocation = .null_handle;

        const result = c.vmaVirtualAllocate(
            self.handle,
            create_info,
            &allocation,
            offset,
        );

        if (result != .success or allocation == .null_handle) {
            return error.FaildToVirtuallyAllocateMemory;
        }

        return allocation;
    }

    /// Frees virtual allocation inside given VmaVirtualBlock.
    ///
    /// It is correct to call this function with allocation == VK_NULL_HANDLE - it does nothing.
    pub fn free(
        self: *VirtualBlock,
        allocation: ?c.VirtualAllocation,
    ) void {
        c.vmaVirtualFree(self.handle, allocation);
    }

    /// Frees all virtual allocations inside given VmaVirtualBlock.
    ///
    /// You must either call this function or free each virtual allocation individually with vmaVirtualFree() before destroying a virtual block. Otherwise, an assert is called.
    ///
    /// If you keep pointer to some additional metadata associated with your virtual allocation in its pUserData, don't forget to free it as well.
    pub fn clear(
        self: *VirtualBlock,
    ) void {
        c.vmaClearVirtualBlock(self.handle);
    }

    /// Returns true of the VmaVirtualBlock is empty - contains 0 virtual allocations and has all its space available for new allocations.
    pub fn isEmpty(
        self: *const VirtualBlock,
    ) bool {
        const result = c.vmaIsVirtualBlockEmpty(self.handle);

        return if (result == vk.TRUE) true else false;
    }

    /// Calculates and returns statistics about virtual allocations and memory usage in given VmaVirtualBlock.
    ///
    /// This function is fast to call. For more detailed statistics, see vmaCalculateVirtualBlockStatistics().
    pub fn getStatistics(
        self: *const VirtualBlock,
    ) c.Statistics {
        var stats: c.Statistics = .{};

        c.vmaGetVirtualBlockStatistics(
            self.handle,
            &stats,
        );

        return stats;
    }

    /// Builds and returns a null-terminated string in JSON format with information about given VmaVirtualBlock.
    pub fn statsStringBuild(
        self: *VirtualBlock,
        stats_string: ?[*][*:0]u8,
        detailed_map: bool,
    ) void {
        c.vmaBuildVirtualBlockStatsString(
            self.handle,
            stats_string,
            if (detailed_map) vk.TRUE else vk.FALSE,
        );
    }

    /// Frees a string returned by vmaBuildVirtualBlockStatsString().
    pub fn statsStringFree(
        self: *VirtualBlock,
        stats_string: ?[*:0]u8,
    ) void {
        c.vmaFreeVirtualBlockStatsString(
            self.handle,
            stats_string,
        );
    }

    /// Calculates and returns detailed statistics about virtual allocations and memory usage in given VmaVirtualBlock.
    ///
    /// This function is slow to call. Use for debugging purposes. For less detailed statistics, see vmaGetVirtualBlockStatistics().
    pub fn calculateStatistics(
        self: *VirtualBlock,
    ) c.DetailedStatistics {
        var stats: c.DetailedStatistics = .{};
        c.vmaCalculateVirtualBlockStatistics(
            self.handle,
            &stats,
        );

        return stats;
    }

    /// Returns information about a specific virtual allocation within a virtual block, like its size and pUserData pointer.
    pub fn allocationGetInfo(
        self: *const VirtualBlock,
        allocation: c.VirtualAllocation,
    ) c.VirtualAllocationInfo {
        var virtual_alloc_info: c.VirtualAllocationInfo = .{};

        c.vmaGetVirtualAllocationInfo(
            self.handle,
            allocation,
            &virtual_alloc_info,
        );

        return virtual_alloc_info;
    }

    /// Changes custom pointer associated with given virtual allocation.
    pub fn allocationSetUserData(
        self: *VirtualBlock,
        allocation: c.VirtualAllocation,
        user_data: ?*anyopaque,
    ) void {
        c.vmaSetVirtualAllocationUserData(
            self.handle,
            allocation,
            user_data,
        );
    }
};

const vk = @import("vulkan");
const c = @import("./c.zig");
