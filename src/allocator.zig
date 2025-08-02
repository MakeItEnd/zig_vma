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
        self: *const VulkanMemoryAllocator,
        memory_type_bits: u32,
    ) vk.Result {
        return c.vmaCheckCorruption(
            self.handle,
            memory_type_bits,
        );
    }

    /// Returns information about existing VmaAllocator object - handle to Vulkan device etc.
    ///
    /// It might be useful if you want to keep just the VmaAllocator handle and fetch other required handles to VkPhysicalDevice, VkDevice etc. every time using this function.
    pub fn getInfo(
        self: *const VulkanMemoryAllocator,
    ) c.AllocatorInfo {
        var allocator_info: c.AllocatorInfo = .{};
        c.vmaGetAllocatorInfo(self.handle, &allocator_info);

        return allocator_info;
    }

    /// Retrieves information about current memory usage and budget for all memory heaps.
    pub fn getHeapBudgets(
        self: *const VulkanMemoryAllocator,
    ) c.Budget {
        var budget: c.Budget = .{};
        c.vmaGetAllocatorInfo(self.handle, &budget);

        return budget;
    }

    /// PhysicalDeviceProperties are fetched from physicalDevice by the allocator. You can access it here, without fetching it again on your own.
    pub fn getPhysicalDeviceProperties(
        self: *const VulkanMemoryAllocator,
    ) vk.PhysicalDeviceProperties {
        var physical_device_properties: vk.PhysicalDeviceProperties = .{};
        c.vmaGetPhysicalDeviceProperties(self.handle, &physical_device_properties);

        return physical_device_properties;
    }

    /// Sets index of the current frame.
    pub fn setCurrentFrameIndex(
        self: *const VulkanMemoryAllocator,
        frame_index: u32,
    ) void {
        c.vmaSetCurrentFrameIndex(self.handle, frame_index);
    }

    // TODO: Check if I should build the string internally and return it.
    /// Builds and returns statistics as a null-terminated string in JSON format.
    pub fn statsBuildString(
        self: *const VulkanMemoryAllocator,
        pp_stats_string: ?[*][*:0]u8,
        detailed_map: bool,
    ) void {
        c.vmaBuildStatsString(
            self.handle,
            pp_stats_string,
            if (detailed_map) vk.TRUE else vk.FALSE,
        );
    }

    pub fn statsFreeString(
        self: *const VulkanMemoryAllocator,
        p_stats_string: ?[*:0]u8,
    ) void {
        c.vmaFreeStatsString(self.handle, p_stats_string);
    }

    /// Retrieves statistics from current state of the Allocator.
    ///
    /// This function is called "calculate" not "get" because it has to traverse all internal data structures, so it may be quite slow. Use it for debugging purposes. For faster but more brief statistics suitable to be called every frame or every allocation, use vmaGetHeapBudgets().
    ///
    /// Note that when using allocator from multiple threads, returned information may immediately become outdated.
    pub fn calculateStatistics(
        self: *const VulkanMemoryAllocator,
    ) c.TotalStatistics {
        var total_statistics: c.TotalStatistics = .{};
        c.vmaCalculateStatistics(
            self.handle,
            &total_statistics,
        );

        return total_statistics;
    }

    /// Begins defragmentation process.
    pub fn defragmentationBegin(
        self: *VulkanMemoryAllocator,
        info: *const c.DefragmentationInfo,
        context: ?*c.DefragmentationContext,
    ) vk.Result {
        return c.vmaBeginDefragmentation(
            self.handle,
            info,
            context,
        );
    }

    /// Ends defragmentation process.
    pub fn defragmentationEnd(
        self: *VulkanMemoryAllocator,
        context: c.DefragmentationContext,
        stats: ?*c.DefragmentationStats,
    ) void {
        c.vmaEndDefragmentation(
            self.handle,
            context,
            stats,
        );
    }

    /// Starts single defragmentation pass.
    pub fn defragmentationPassBegin(
        self: *VulkanMemoryAllocator,
        context: c.DefragmentationContext,
        pass_info: *c.DefragmentationPassMoveInfo,
    ) vk.Result {
        return c.vmaBeginDefragmentationPass(
            self.handle,
            context,
            pass_info,
        );
    }

    /// Ends single defragmentation pass.
    pub fn defragmentationPassEnd(
        self: *VulkanMemoryAllocator,
        context: c.DefragmentationContext,
        pass_info: *c.DefragmentationPassMoveInfo,
    ) vk.Result {
        return c.vmaEndDefragmentationPass(
            self.handle,
            context,
            pass_info,
        );
    }

    /// General purpose memory allocation.
    pub fn memoryAllocate(
        self: *VulkanMemoryAllocator,
        vk_memory_requirements: *const vk.MemoryRequirements,
        create_info: *const c.AllocationCreateInfo,
        allocation_info: ?*c.AllocationInfo,
    ) !c.Allocation {
        var allocation: ?*c.Allocation = .null_handle;

        const result = c.vmaAllocateMemory(
            self.handle,
            vk_memory_requirements,
            create_info,
            &allocation,
            allocation_info,
        );

        if (result != .success or allocation == .null_handle) {
            return error.FaildToAllocateMemory;
        }

        return c.Allocation;
    }
};

const vk = @import("vulkan");
const c = @import("./c.zig");
