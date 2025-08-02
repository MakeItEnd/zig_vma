// Handles --------------------------------------------------------------------
// ----------------------------------------------------------------------------
/// Represents main object of this library initialized.
pub const Allocator = enum(usize) { null_handle = 0, _ };

/// Represents custom memory pool.
pub const Pool = enum(usize) { null_handle = 0, _ };

/// Represents single memory allocation.
pub const Allocation = enum(usize) { null_handle = 0, _ };

/// An opaque object that represents started defragmentation process.
pub const DefragmentationContext = enum(usize) { null_handle = 0, _ };

/// Represents single memory allocation done inside VmaVirtualBlock.
pub const VirtualAllocation = enum(u64) { null_handle = 0, _ };

/// Handle to a virtual block object that allows to use core allocation algorithm without allocating any real GPU memory.
pub const VirtualBlock = enum(usize) { null_handle = 0, _ };

// Functions ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// Structs --------------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Parameters of new VmaAllocation.
pub const AllocationCreateInfo = extern struct {
    flags: AllocationCreateFlags = .{},
    usage: MemoryUsage,
    required_flags: vk.MemoryPropertyFlags = .{},
    preferred_flags: vk.MemoryPropertyFlags = .{},
    memory_type_bits: u32 = 0,
    pool: ?Pool = null,
    p_user_data: ?*anyopaque = null,
    priority: f32 = 0.0,
};

pub const AllocationInfo = extern struct {
    memory_type: u32,
    device_memory: vk.DeviceMemory,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
    p_mapped_data: ?*anyopaque = null,
    p_user_data: ?*anyopaque = null,
    p_name: ?[*:0]const u8 = null,
};

/// Extended parameters of a VmaAllocation object that can be retrieved using function vmaGetAllocationInfo2().
pub const AllocationInfo2 = extern struct {
    allocation_info: AllocationInfo,
    block_size: vk.DeviceSize,
    dedicated_memory: vk.Bool32,
};

/// Description of a Allocator to be created.
pub const AllocatorCreateInfo = extern struct {
    flags: AllocatorCreateFlags = .{},
    physical_device: vk.PhysicalDevice,
    device: vk.Device,
    preferred_large_heap_block_size: vk.DeviceSize = 0,
    p_allocation_callbacks: ?[*]const vk.AllocationCallbacks = null,
    p_device_memory_callbacks: ?[*]const DeviceMemoryCallbacks = null,
    p_heap_size_limit: ?[*]const vk.DeviceSize = null,
    p_vulkan_functions: [*]const VulkanFunctions,
    instance: vk.Instance,
    vulkan_api_version: u32,
    p_type_external_memory_handle_types: ?[*]vk.ExternalMemoryHandleTypeFlagsKHR = null,
};

/// Information about existing VmaAllocator object.
pub const AllocatorInfo = extern struct {
    instance: vk.Instance,
    physical_device: vk.PhysicalDevice,
    device: vk.Device,
};

/// Statistics of current memory usage and available budget for a specific memory heap.
pub const Budget = extern struct {
    statistics: Statistics,
    usage: vk.DeviceSize,
    budget: vk.DeviceSize,
};

/// Parameters for defragmentation.
pub const DefragmentationInfo = extern struct {
    flags: DefragmentationFlags = .{},
    pool: ?Pool = null,
    max_bytes_per_pass: vk.DeviceSize = 0,
    max_allocations_per_pass: u32 = 0,
    pfn_break_callback: ?PfnVmaCheckDefragmentationBreakFunction = null,
    p_break_callback_user_data: ?*anyopaque = null,
};

/// Single move of an allocation to be done for defragmentation.
pub const DefragmentationMove = extern struct {
    operation: DefragmentationMoveOperation = .copy,
    src_allocation: Allocation,
    dst_tmp_allocation: Allocation,
};

/// Parameters for incremental defragmentation steps.
pub const DefragmentationPassMoveInfo = extern struct {
    move_count: u32,
    p_moves: ?[*]DefragmentationMove = null,
};

/// Statistics returned for defragmentation process in function vmaEndDefragmentation().
pub const DefragmentationStats = extern struct {
    bytes_moved: vk.DeviceSize,
    bytes_freed: vk.DeviceSize,
    allocations_moved: u32,
    device_memory_blocks_freed: u32,
};

/// More detailed statistics than VmaStatistics.
pub const DetailedStatistics = extern struct {
    statistics: Statistics,
    unused_range_count: u32,
    allocation_size_min: vk.DeviceSize,
    allocation_size_max: vk.DeviceSize,
    unused_range_size_min: vk.DeviceSize,
    unused_range_size_max: vk.DeviceSize,
};

/// Set of callbacks that the library will call for vkAllocateMemory and vkFreeMemory.
///
/// Provided for informative purpose, e.g. to gather statistics about number of
/// allocations or total amount of memory allocated in Vulkan.
pub const DeviceMemoryCallbacks = extern struct {
    pfn_allocate: PfnVmaAllocateDeviceMemoryFunction = null,
    pfn_free: PfnVmaFreeDeviceMemoryFunction = null,
    p_user_data: ?*anyopaque,
};

/// Describes parameter of created VmaPool.
pub const PoolCreateInfo = extern struct {
    memory_type_index: u32,
    flags: PoolCreateFlags = .{},
    block_size: vk.DeviceSize = 0,
    min_block_count: usize = 0,
    max_block_count: usize = 0,
    priority: f32 = 0.0,
    min_allocation_alignment: vk.DeviceSize = 0,
    p_memory_allocate_next: ?*anyopaque = null,
};

/// Calculated statistics of memory usage e.g. in a specific memory type, heap, custom pool, or total.
pub const Statistics = extern struct {
    block_count: u32,
    allocation_count: u32,
    block_bytes: vk.DeviceSize,
    allocation_bytes: vk.DeviceSize,
};

/// General statistics from current state of the Allocator - total memory usage across all memory heaps and types.
pub const TotalStatistics = extern struct {
    memory_type: [vk.MAX_MEMORY_TYPES]DetailedStatistics,
    memory_heap: [vk.MAX_MEMORY_HEAPS]DetailedStatistics,
    total: DetailedStatistics,
};

/// Parameters of created virtual allocation to be passed to vmaVirtualAllocate().
pub const VirtualAllocationCreateInfo = extern struct {
    statistics: Statistics,
    unused_range_count: u32,
    allocation_size_min: vk.DeviceSize,
    allocation_size_max: vk.DeviceSize,
    unused_range_size_min: vk.DeviceSize,
    unused_range_size_max: vk.DeviceSize,
};

/// Parameters of an existing virtual allocation, returned by vmaGetVirtualAllocationInfo().
pub const VirtualAllocationInfo = extern struct {
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
    p_user_data: ?*anyopaque = null,
};

/// Parameters of created VmaVirtualBlock object to be passed to vmaCreateVirtualBlock().
pub const VirtualBlockCreateInfo = extern struct {
    size: vk.DeviceSize,
    flags: VirtualBlockCreateFlags = .{},
    p_allocation_callbacks: ?[*]vk.AllocationCallbacks = null,
};

/// Pointers to some Vulkan functions - a subset used by the library.
pub const VulkanFunctions = extern struct {
    /// Required when using VMA_DYNAMIC_VULKAN_FUNCTIONS.
    vkGetInstanceProcAddr: vk.PfnGetInstanceProcAddr,
    /// Required when using VMA_DYNAMIC_VULKAN_FUNCTIONS.
    vkGetDeviceProcAddr: vk.PfnGetDeviceProcAddr,
    vkGetPhysicalDeviceProperties: ?vk.PfnGetPhysicalDeviceProperties = null,
    vkGetPhysicalDeviceMemoryProperties: ?vk.PfnGetPhysicalDeviceMemoryProperties = null,
    vkAllocateMemory: ?vk.PfnAllocateMemory = null,
    vkFreeMemory: ?vk.PfnFreeMemory = null,
    vkMapMemory: ?vk.PfnMapMemory = null,
    vkUnmapMemory: ?vk.PfnUnmapMemory = null,
    vkFlushMappedMemoryRanges: ?vk.PfnFlushMappedMemoryRanges = null,
    vkInvalidateMappedMemoryRanges: ?vk.PfnInvalidateMappedMemoryRanges = null,
    vkBindBufferMemory: ?vk.PfnBindBufferMemory = null,
    vkBindImageMemory: ?vk.PfnBindImageMemory = null,
    vkGetBufferMemoryRequirements: ?vk.PfnGetBufferMemoryRequirements = null,
    vkGetImageMemoryRequirements: ?vk.PfnGetImageMemoryRequirements = null,
    vkCreateBuffer: ?vk.PfnCreateBuffer = null,
    vkDestroyBuffer: ?vk.PfnDestroyBuffer = null,
    vkCreateImage: ?vk.PfnCreateImage = null,
    vkDestroyImage: ?vk.PfnDestroyImage = null,
    vkCmdCopyBuffer: ?vk.PfnCmdCopyBuffer = null,
    /// Fetch "vkGetBufferMemoryRequirements2" on Vulkan >= 1.1, fetch "vkGetBufferMemoryRequirements2KHR" when using VK_KHR_dedicated_allocation extension.
    vkGetBufferMemoryRequirements2KHR: ?vk.PfnGetBufferMemoryRequirements2KHR = null,
    /// Fetch "vkGetImageMemoryRequirements2" on Vulkan >= 1.1, fetch "vkGetImageMemoryRequirements2KHR" when using VK_KHR_dedicated_allocation extension.
    vkGetImageMemoryRequirements2KHR: ?vk.PfnGetImageMemoryRequirements2KHR = null,
    /// Fetch "vkBindBufferMemory2" on Vulkan >= 1.1, fetch "vkBindBufferMemory2KHR" when using VK_KHR_bind_memory2 extension.
    vkBindBufferMemory2KHR: ?vk.PfnBindBufferMemory2KHR = null,
    /// Fetch "vkBindImageMemory2" on Vulkan >= 1.1, fetch "vkBindImageMemory2KHR" when using VK_KHR_bind_memory2 extension.
    vkBindImageMemory2KHR: ?vk.PfnBindImageMemory2KHR = null,
    /// Fetch from "vkGetPhysicalDeviceMemoryProperties2" on Vulkan >= 1.1, but you can also fetch it from "vkGetPhysicalDeviceMemoryProperties2KHR" if you enabled extension VK_KHR_get_physical_device_properties2.
    vkGetPhysicalDeviceMemoryProperties2KHR: ?vk.PfnGetPhysicalDeviceMemoryProperties2KHR = null,
    /// Fetch from "vkGetDeviceBufferMemoryRequirements" on Vulkan >= 1.3, but you can also fetch it from "vkGetDeviceBufferMemoryRequirementsKHR" if you enabled extension VK_KHR_maintenance4.
    vkGetDeviceBufferMemoryRequirements: ?vk.PfnGetDeviceBufferMemoryRequirements = null,
    /// Fetch from "vkGetDeviceImageMemoryRequirements" on Vulkan >= 1.3, but you can also fetch it from "vkGetDeviceImageMemoryRequirementsKHR" if you enabled extension VK_KHR_maintenance4.
    vkGetDeviceImageMemoryRequirements: ?vk.PfnGetDeviceImageMemoryRequirements = null,
    vkGetMemoryWin32HandleKHR: ?vk.PfnGetMemoryWin32HandleKHR = null,
};

const vk = @import("vulkan");

const AllocationCreateFlags = @import("./flags.zig").AllocationCreateFlags;
const AllocatorCreateFlags = @import("./flags.zig").AllocatorCreateFlags;
const DefragmentationFlags = @import("./flags.zig").DefragmentationFlags;
const DefragmentationMoveOperation = @import("./flags.zig").DefragmentationMoveOperation;
const MemoryUsage = @import("./flags.zig").MemoryUsage;
const PoolCreateFlags = @import("./flags.zig").PoolCreateFlags;
const VirtualBlockCreateFlags = @import("./flags.zig").VirtualBlockCreateFlags;

const PfnVmaAllocateDeviceMemoryFunction = @import("./functions.zig").PfnVmaAllocateDeviceMemoryFunction;
const PfnVmaCheckDefragmentationBreakFunction = @import("./functions.zig").PfnVmaCheckDefragmentationBreakFunction;
const PfnVmaFreeDeviceMemoryFunction = @import("./functions.zig").PfnVmaFreeDeviceMemoryFunction;
