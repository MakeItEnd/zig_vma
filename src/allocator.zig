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
        var allocation: c.Allocation = .null_handle;

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

        return allocation;
    }

    /// Allocates memory suitable for given VkBuffer.
    pub fn memoryAllocateForBuffer(
        self: *VulkanMemoryAllocator,
        buffer: vk.Buffer,
        create_info: *const c.AllocationCreateInfo,
        allocation_info: ?*c.AllocationInfo,
    ) !c.Allocation {
        var allocation: c.Allocation = .null_handle;

        const result = c.vmaAllocateMemoryForBuffer(
            self.handle,
            buffer,
            create_info,
            &allocation,
            allocation_info,
        );

        if (result != .success or allocation == .null_handle) {
            return error.FaildToAllocateMemoryForBuffer;
        }

        return allocation;
    }

    /// Allocates memory suitable for given VkImage.
    pub fn memoryAllocateForImage(
        self: *VulkanMemoryAllocator,
        image: vk.Image,
        create_info: *const c.AllocationCreateInfo,
        allocation_info: ?*c.AllocationInfo,
    ) !c.Allocation {
        var allocation: c.Allocation = .null_handle;

        const result = c.vmaAllocateMemoryForImage(
            self.handle,
            image,
            create_info,
            &allocation,
            allocation_info,
        );

        if (result != .success or allocation == .null_handle) {
            return error.FaildToAllocateMemoryForImage;
        }

        return allocation;
    }

    /// General purpose memory allocation for multiple allocation objects at once.
    pub fn memoryPagesAllocate(
        self: *VulkanMemoryAllocator,
        vk_memory_requirements: *const vk.MemoryRequirements,
        create_info: *const c.AllocationCreateInfo,
        allocation_count: usize,
        allocation_info: ?*c.AllocationInfo,
    ) !c.Allocation {
        var allocation: c.Allocation = .null_handle;

        const result = c.vmaAllocateMemoryPages(
            self.handle,
            vk_memory_requirements,
            create_info,
            allocation_count,
            &allocation,
            allocation_info,
        );

        if (result != .success or allocation == .null_handle) {
            return error.FaildToAllocateMemoryForPages;
        }

        return allocation;
    }

    /// Frees memory previously allocated using vmaAllocateMemory(), vmaAllocateMemoryForBuffer(), or vmaAllocateMemoryForImage().
    pub fn memoryFree(
        self: *VulkanMemoryAllocator,
        allocation: ?c.Allocation,
    ) void {
        c.vmaFreeMemory(self.handle, allocation);
    }

    /// Frees memory and destroys multiple allocations.
    pub fn memoryPagesFree(
        self: *VulkanMemoryAllocator,
        allocation_count: usize,
        allocations: ?*const c.Allocation,
    ) void {
        c.vmaFreeMemoryPages(
            self.handle,
            allocation_count,
            allocations,
        );
    }

    /// Helps to find memoryTypeIndex, given memoryTypeBits and VmaAllocationCreateInfo.
    pub fn memoryFindTypeIndex(
        self: *VulkanMemoryAllocator,
        memory_type_bits: u32,
        allocation_create_info: *const c.AllocationCreateInfo,
    ) u32 {
        var memory_type_index: u32 = undefined;

        const result = c.vmaFindMemoryTypeIndex(
            self.handle,
            memory_type_bits,
            allocation_create_info,
            &memory_type_index,
        );

        if (result != .success) {
            return error.FeatureNotPresent;
        }

        return memory_type_index;
    }

    /// PhysicalDeviceMemoryProperties are fetched from physicalDevice by the allocator. You can access it here, without fetching it again on your own.
    pub fn memoryGetProperties(
        self: *VulkanMemoryAllocator,
    ) vk.PhysicalDeviceMemoryProperties {
        var physical_device_memory_properties: vk.PhysicalDeviceMemoryProperties = .{};

        c.vmaGetMemoryProperties(
            self.handle,
            &physical_device_memory_properties,
        );

        return physical_device_memory_properties;
    }

    /// Given Memory Type Index, returns Property Flags of this memory type.
    ///
    /// This is just a convenience function. Same information can be obtained using vmaGetMemoryProperties().
    pub fn memoryGetTypeProperties(
        self: *VulkanMemoryAllocator,
        memory_type_index: u32,
    ) vk.MemoryPropertyFlags {
        var flags: vk.MemoryPropertyFlags = .{};

        c.vmaGetMemoryTypeProperties(
            self.handle,
            memory_type_index,
            &flags,
        );

        return flags;
    }

    /// Maps memory represented by given allocation and returns pointer to it.
    pub fn memoryMap(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        data: ?[*]*anyopaque,
    ) !void {
        const result = c.vmaMapMemory(
            self.handle,
            allocation,
            data,
        );

        if (result != .success) {
            return error.FailedToMapMemory;
        }
    }

    /// Unmaps memory represented by given allocation, mapped previously using vmaMapMemory().
    pub fn memoryUnmap(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
    ) void {
        c.vmaUnmapMemory(self.handle, allocation);
    }

    /// Maps the allocation temporarily if needed, copies data from specified host pointer to it, and flushes the memory from the host caches if needed.
    pub fn memoryCopyToAllocation(
        self: *VulkanMemoryAllocator,
        src_host_pointer: *const anyopaque,
        dst_allocation: c.Allocation,
        dst_allocation_local_offset: vk.DeviceSize,
        size: vk.DeviceSize,
    ) vk.Result {
        return c.vmaCopyMemoryToAllocation(
            self.handle,
            src_host_pointer,
            dst_allocation,
            dst_allocation_local_offset,
            size,
        );
    }

    /// Given an allocation, returns Win32 handle that may be imported by other processes or APIs.
    pub fn memoryGetWin32Handle(
        self: *const VulkanMemoryAllocator,
        allocation: c.Allocation,
        hTargetProcess: c.HANDLE,
        Handle: ?*c.HANDLE,
    ) vk.Result {
        return c.vmaGetMemoryWin32Handle(
            self.handle,
            allocation,
            hTargetProcess,
            Handle,
        );
    }

    /// Flushes memory of given allocation.
    pub fn allocationFlush(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        offset: vk.DeviceSize,
        size: vk.DeviceSize,
    ) vk.Result {
        return c.vmaFlushAllocation(
            self.handle,
            allocation,
            offset,
            size,
        );
    }

    /// Flushes memory of given set of allocations.
    pub fn allocationsFlush(
        self: *VulkanMemoryAllocator,
        allocation_count: u32,
        allocations: ?*const c.Allocation,
        offsets: ?*const vk.DeviceSize,
        sizes: ?*const vk.DeviceSize,
    ) vk.Result {
        return c.vmaFlushAllocations(
            self.handle,
            allocation_count,
            allocations,
            offsets,
            sizes,
        );
    }

    /// Returns current information about specified allocation.
    pub fn allocationGetInfo(
        self: *const VulkanMemoryAllocator,
        allocation: c.Allocation,
    ) c.AllocationInfo {
        var allocation_info: c.AllocationInfo = .{};

        c.vmaGetAllocationInfo(
            self.handle,
            allocation,
            &allocation_info,
        );

        return allocation_info;
    }

    /// Returns extended information about specified allocation.
    pub fn allocationGetInfo2(
        self: *const VulkanMemoryAllocator,
        allocation: c.Allocation,
    ) c.AllocationInfo2 {
        var allocation_info: c.AllocationInfo2 = .{};

        c.vmaGetAllocationInfo2(
            self.handle,
            allocation,
            &allocation_info,
        );

        return allocation_info;
    }

    /// Given an allocation, returns Property Flags of its memory type.
    pub fn allocationGetMemoryProperties(
        self: *const VulkanMemoryAllocator,
        allocation: c.Allocation,
    ) vk.MemoryPropertyFlags {
        var flags: vk.MemoryPropertyFlags = .{};

        c.vmaGetAllocationMemoryProperties(
            self.handle,
            allocation,
            &flags,
        );

        return flags;
    }

    /// Invalidates memory of given allocation.
    pub fn allocationInvalidate(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        offset: vk.DeviceSize,
        size: vk.DeviceSize,
    ) vk.Result {
        return c.vmaInvalidateAllocation(
            self.handle,
            allocation,
            offset,
            size,
        );
    }

    /// Invalidates memory of given set of allocations.
    pub fn allocationsInvalidate(
        self: *VulkanMemoryAllocator,
        allocation_count: u32,
        allocations: ?*const c.Allocation,
        offsets: ?*const vk.DeviceSize,
        sizes: ?*const vk.DeviceSize,
    ) vk.Result {
        return c.vmaInvalidateAllocations(
            self.handle,
            allocation_count,
            allocations,
            offsets,
            sizes,
        );
    }

    /// Sets pName in given allocation to new value.
    pub fn allocationSetName(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        name: ?[*:0]const u8,
    ) void {
        c.vmaSetAllocationName(
            self.handle,
            allocation,
            name,
        );
    }

    /// Sets `user_data` in given allocation to new value.
    pub fn allocationSetUserData(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        user_data: ?*anyopaque,
    ) void {
        c.vmaSetAllocationUserData(
            self.handle,
            allocation,
            user_data,
        );
    }

    /// Invalidates memory in the host caches if needed, maps the allocation temporarily if needed, and copies data from it to a specified host pointer.
    pub fn allocationCopyToMemory(
        self: *VulkanMemoryAllocator,
        src_allocation: c.Allocation,
        src_allocation_local_offset: vk.DeviceSize,
        dst_host_pointer: *anyopaque,
        size: vk.DeviceSize,
    ) vk.Result {
        return c.vmaCopyAllocationToMemory(
            self.handle,
            src_allocation,
            src_allocation_local_offset,
            dst_host_pointer,
            size,
        );
    }

    /// Allocates Vulkan device memory and creates VmaPool object.
    pub fn poolCreate(
        self: *VulkanMemoryAllocator,
        create_info: *c.PoolCreateInfo,
    ) !c.Pool {
        var pool: c.Pool = .null_handle;

        const result = c.vmaCreatePool(
            self.handle,
            create_info,
            &pool,
        );

        if (result != .success or pool == .null_handle) {
            return error.FailedToCreatePool;
        }

        return pool;
    }

    /// Destroys VmaPool object and frees Vulkan device memory.
    pub fn poolDestroy(
        self: *VulkanMemoryAllocator,
        pool: c.Pool,
    ) vk.Result {
        return c.vmaDestroyPool(
            self.handle,
            pool,
        );
    }

    /// Retrieves name of a custom pool.
    pub fn poolNameGet(
        self: *const VulkanMemoryAllocator,
        pool: c.Pool,
        name: ?[*:0]const u8,
    ) void {
        c.vmaGetPoolName(
            self.handle,
            pool,
            name,
        );
    }

    /// Sets name of a custom pool.
    pub fn poolNameSet(
        self: *VulkanMemoryAllocator,
        pool: c.Pool,
        name: ?[*:0]const u8,
    ) void {
        c.vmaSetPoolName(
            self.handle,
            pool,
            name,
        );
    }

    /// Checks magic number in margins around all allocations in given memory pool in search for corruptions.
    pub fn poolCheckCorruption(
        self: *const VulkanMemoryAllocator,
        pool: c.Pool,
    ) vk.Result {
        return c.vmaCheckPoolCorruption(
            self.handle,
            pool,
        );
    }

    /// Retrieves statistics of existing VmaPool object.
    pub fn poolGetStatistics(
        self: *const VulkanMemoryAllocator,
        pool: c.Pool,
    ) c.Statistics {
        var pool_stats: c.Statistics = .{};

        c.vmaGetPoolStatistics(
            self.handle,
            pool,
            &pool_stats,
        );

        return pool_stats;
    }

    /// Retrieves detailed statistics of existing VmaPool object.
    pub fn poolCalculateStatistics(
        self: *const VulkanMemoryAllocator,
        pool: c.Pool,
    ) c.DetailedStatistics {
        var pool_stats: c.DetailedStatistics = .{};

        c.vmaCalculatePoolStatistics(
            self.handle,
            pool,
            &pool_stats,
        );

        return pool_stats;
    }

    /// Creates a new VkBuffer, allocates and binds memory for it.
    pub fn bufferCreate(
        self: *VulkanMemoryAllocator,
        buffer_create_info: *const vk.BufferCreateInfo,
        allocation_create_info: *const c.AllocationCreateInfo,
        allocation: ?*c.Allocation,
        allocation_info: ?*c.AllocationInfo,
    ) !vk.Buffer {
        var buffer: vk.Buffer = .null_handle;

        const result = c.vmaCreateBuffer(
            self.handle,
            buffer_create_info,
            allocation_create_info,
            &buffer,
            allocation,
            allocation_info,
        );

        if (result != .success or buffer == .null_handle) {
            return error.FailedToCreateBuffer;
        }

        return buffer;
    }

    /// Creates a buffer with additional minimum alignment.
    pub fn bufferCreateWithAlignment(
        self: *VulkanMemoryAllocator,
        buffer_create_info: *const vk.BufferCreateInfo,
        allocation_create_info: *const c.AllocationCreateInfo,
        min_alignment: vk.DeviceSize,
        allocation: ?*c.Allocation,
        allocation_info: ?*c.AllocationInfo,
    ) !vk.Buffer {
        var buffer: vk.Buffer = .null_handle;

        const result = c.vmaCreateBufferWithAlignment(
            self.handle,
            buffer_create_info,
            allocation_create_info,
            min_alignment,
            &buffer,
            allocation,
            allocation_info,
        );

        if (result != .success or buffer == .null_handle) {
            return error.FailedToCreateBuffer;
        }

        return buffer;
    }

    /// Creates a new VkBuffer, binds already created memory for it.
    pub fn bufferCreateAliasing(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        buffer_create_info: *const vk.BufferCreateInfo,
    ) !vk.Buffer {
        var buffer: vk.Buffer = .null_handle;

        const result = c.vmaCreateAliasingBuffer(
            self.handle,
            allocation,
            buffer_create_info,
            &buffer,
        );

        if (result != .success or buffer == .null_handle) {
            return error.FailedToCreateBuffer;
        }

        return buffer;
    }

    /// Creates a new VkBuffer, binds already created memory for it.
    pub fn bufferCreateAliasing2(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        allocation_local_offset: vk.DeviceSize,
        buffer_create_info: *const vk.BufferCreateInfo,
    ) !vk.Buffer {
        var buffer: vk.Buffer = .null_handle;

        const result = c.vmaCreateAliasingBuffer2(
            self.handle,
            allocation,
            allocation_local_offset,
            buffer_create_info,
            &buffer,
        );

        if (result != .success or buffer == .null_handle) {
            return error.FailedToCreateBuffer;
        }

        return buffer;
    }

    /// Destroys Vulkan buffer and frees allocated memory.
    pub fn bufferDestroy(
        self: *VulkanMemoryAllocator,
        buffer: ?vk.Buffer,
        allocation: ?c.Allocation,
    ) void {
        c.vmaDestroyBuffer(
            self.handle,
            buffer,
            allocation,
        );
    }

    /// Binds buffer to allocation.
    pub fn bufferBindMemory(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        buffer: vk.Buffer,
    ) vk.Result {
        return c.vmaBindBufferMemory(
            self.handle,
            allocation,
            buffer,
        );
    }

    /// Binds buffer to allocation with additional parameters.
    pub fn bufferBindMemory2(
        self: *VulkanMemoryAllocator,
        allocation: c.Allocation,
        allocation_local_offset: vk.DeviceSize,
        buffer: vk.Buffer,
        p_next: ?*const anyopaque,
    ) vk.Result {
        return c.vmaBindBufferMemory2(
            self.handle,
            allocation,
            allocation_local_offset,
            buffer,
            p_next,
        );
    }

    /// Helps to find memoryTypeIndex, given VkBufferCreateInfo and VmaAllocationCreateInfo.
    pub fn bufferMemoryFindTypeIndex(
        self: *const VulkanMemoryAllocator,
        buffer_create_info: *const vk.BufferCreateInfo,
        allocation_create_info: *const c.AllocationCreateInfo,
    ) !u32 {
        var memory_type_index: u32 = undefined;

        const result = c.vmaFindMemoryTypeIndexForBufferInfo(
            self.handle,
            buffer_create_info,
            allocation_create_info,
            &memory_type_index,
        );

        if (result != .success) {
            return error.FeatureNotPresent;
        }

        return memory_type_index;
    }
};

const vk = @import("vulkan");
const c = @import("./c.zig");
