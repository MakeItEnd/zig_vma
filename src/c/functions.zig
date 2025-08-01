//! All vma functions

pub const vulkan_call_conv: std.builtin.CallingConvention = if (builtin.os.tag == .windows and builtin.cpu.arch == .x86)
    .Stdcall
else if (builtin.abi == .android and (builtin.cpu.arch.isARM() or builtin.cpu.arch.isThumb()) and std.Target.arm.featureSetHas(builtin.cpu.features, .has_v7) and builtin.cpu.arch.ptrBitWidth() == 32)
    // On Android 32-bit ARM targets, Vulkan functions use the "hardfloat"
    // calling convention, i.e. float parameters are passed in registers. This
    // is true even if the rest of the application passes floats on the stack,
    // as it does by default when compiling for the armeabi-v7a NDK ABI.
    .AAPCSVFP
else
    .C;

/// Helps to find memoryTypeIndex, given memoryTypeBits and VmaAllocationCreateInfo.
pub extern fn vmaFindMemoryTypeIndex(
    allocator: Allocator,
    memory_type_bits: u32,
    p_allocation_create_info: *const AllocationCreateInfo,
    p_memory_type_index: *u32,
) vk.Result;

/// Helps to find memoryTypeIndex, given VkBufferCreateInfo and VmaAllocationCreateInfo.
pub extern fn vmaFindMemoryTypeIndexForBufferInfo(
    allocator: Allocator,
    p_buffer_create_info: *const vk.BufferCreateInfo,
    p_allocation_create_info: *const AllocationCreateInfo,
    p_memory_type_index: *u32,
) vk.Result;

/// Helps to find memoryTypeIndex, given VkImageCreateInfo and VmaAllocationCreateInfo.
pub extern fn vmaFindMemoryTypeIndexForImageInfo(
    allocator: Allocator,
    p_image_create_info: *const vk.ImageCreateInfo,
    p_allocation_create_info: *const AllocationCreateInfo,
    p_memory_type_index: *u32,
) vk.Result;

/// Allocates Vulkan device memory and creates VmaPool object.
pub extern fn vmaCreatePool(
    allocator: Allocator,
    p_create_info: *PoolCreateInfo,
    p_pool: ?*Pool,
) vk.Result;

/// Creates new VmaVirtualBlock object.
pub extern fn vmaCreateVirtualBlock(
    p_create_info: *const VirtualBlockCreateInfo,
    p_virtual_block: ?*VirtualBlock,
) vk.Result;

/// Destroys allocator object.
pub extern fn vmaDestroyAllocator(
    allocator: Allocator,
) void;

/// Destroys VmaPool object and frees Vulkan device memory.
pub extern fn vmaDestroyPool(
    allocator: Allocator,
    p_pool: Pool,
) vk.Result;

/// Destroys VmaVirtualBlock object.
///
/// Please note that you should consciously handle virtual allocations that could remain unfreed in the block. You should either free them individually using vmaVirtualFree() or call vmaClearVirtualBlock() if you are sure this is what you want. If you do neither, an assert is called.
///
/// If you keep pointers to some additional metadata associated with your virtual allocations in their pUserData, don't forget to free them.
pub extern fn vmaDestroyVirtualBlock(
    virtual_block: ?VirtualBlock,
) void;

/// Checks magic number in margins around all allocations in given memory pool in search for corruptions.
pub extern fn vmaCheckPoolCorruption(
    allocator: Allocator,
    pool: Pool,
) vk.Result;

/// Frees all virtual allocations inside given VmaVirtualBlock.
///
/// You must either call this function or free each virtual allocation individually with vmaVirtualFree() before destroying a virtual block. Otherwise, an assert is called.
///
/// If you keep pointer to some additional metadata associated with your virtual allocation in its pUserData, don't forget to free it as well.
pub extern fn vmaClearVirtualBlock(
    virtual_block: VirtualBlock,
) void;

/// Retrieves name of a custom pool.
pub extern fn vmaGetPoolName(
    allocator: Allocator,
    pool: Pool,
    pp_name: ?[*:0]const u8,
) void;

/// Retrieves statistics of existing VmaPool object.
pub extern fn vmaGetPoolStatistics(
    allocator: Allocator,
    pool: Pool,
    p_pool_stats: *Statistics,
) void;

/// Returns information about a specific virtual allocation within a virtual block, like its size and pUserData pointer.
pub extern fn vmaGetVirtualAllocationInfo(
    virtual_block: VirtualBlock,
    allocation: VirtualAllocation,
    p_virtual_alloc_info: *VirtualAllocationInfo,
) void;

/// Calculates and returns statistics about virtual allocations and memory usage in given VmaVirtualBlock.
///
/// This function is fast to call. For more detailed statistics, see vmaCalculateVirtualBlockStatistics().
pub extern fn vmaGetVirtualBlockStatistics(
    virtual_block: VirtualBlock,
    p_stats: *Statistics,
) void;

/// ## Not sure this function is useful in this libraries context.
/// Fully initializes pDstVulkanFunctions structure with Vulkan functions needed by VMA using volk library.
///
/// Read the docs its more involved: https://gpuopen-librariesandsdks.github.io/VulkanMemoryAllocator/html/group__group__init.html#gaf8d9ee01910a7af7f552145ef0065b9c
pub extern fn vmaImportVulkanFunctionsFromVolk(
    p_allocator_create_info: *const AllocationCreateInfo,
    p_dst_vulkan_functions: *VulkanFunctions,
) vk.Result;

/// Sets name of a custom pool.
pub extern fn vmaSetPoolName(
    allocator: Allocator,
    pool: Pool,
    p_name: ?[*:0]const u8,
) void;

/// Changes custom pointer associated with given virtual allocation.
pub extern fn vmaSetVirtualAllocationUserData(
    virtual_block: VirtualBlock,
    allocation: VirtualAllocation,
    p_user_data: ?*anyopaque,
) void;

/// General purpose memory allocation.
pub extern fn vmaAllocateMemory(
    allocator: Allocator,
    p_vk_memory_requirements: *const vk.MemoryRequirements,
    p_create_info: *const AllocationCreateInfo,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// General purpose memory allocation for multiple allocation objects at once.
pub extern fn vmaAllocateMemoryPages(
    allocator: Allocator,
    p_vk_memory_requirements: ?*const vk.MemoryRequirements,
    p_create_info: ?*const AllocationCreateInfo,
    allocation_count: usize,
    p_allocations: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Allocates memory suitable for given VkBuffer.
pub extern fn vmaAllocateMemoryForBuffer(
    allocator: Allocator,
    buffer: vk.Buffer,
    p_create_info: *const AllocationCreateInfo,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Allocates memory suitable for given VkImage.
pub extern fn vmaAllocateMemoryForImage(
    allocator: Allocator,
    image: vk.Image,
    p_create_info: *const AllocationCreateInfo,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Frees memory previously allocated using vmaAllocateMemory(), vmaAllocateMemoryForBuffer(), or vmaAllocateMemoryForImage().
pub extern fn vmaFreeMemory(allocator: Allocator, allocation: ?Allocation) void;

/// Frees memory and destroys multiple allocations.
pub extern fn vmaFreeMemoryPages(
    allocator: Allocator,
    allocation_count: usize,
    p_allocations: ?*const Allocation,
) void;

pub extern fn vmaFreeStatsString(
    allocator: Allocator,
    p_stats_string: ?[*:0]u8,
) void;

/// Frees a string returned by vmaBuildVirtualBlockStatsString().
pub extern fn vmaFreeVirtualBlockStatsString(
    virtual_block: VirtualBlock,
    p_stats_string: ?[*:0]u8,
) void;

/// Returns current information about specified allocation.
pub extern fn vmaGetAllocationInfo(
    allocator: Allocator,
    allocation: Allocation,
    p_allocation_info: *AllocationInfo,
) void;

/// Returns extended information about specified allocation.
pub extern fn vmaGetAllocationInfo2(
    allocator: Allocator,
    allocation: Allocation,
    p_allocation_info: *AllocationInfo2,
) void;

/// Sets pUserData in given allocation to new value.
pub extern fn vmaSetAllocationUserData(
    allocator: Allocator,
    allocation: Allocation,
    p_user_data: ?*anyopaque,
) void;

/// Sets index of the current frame.
pub extern fn vmaSetCurrentFrameIndex(
    allocator: Allocator,
    frame_index: u32,
) void;

/// Sets pName in given allocation to new value.
pub extern fn vmaSetAllocationName(
    allocator: Allocator,
    allocation: Allocation,
    p_name: ?[*:0]const u8,
) void;

/// Given an allocation, returns Property Flags of its memory type.
pub extern fn vmaGetAllocationMemoryProperties(
    allocator: Allocator,
    allocation: Allocation,
    p_flags: [*]vk.MemoryPropertyFlags,
) void;

/// Returns information about existing VmaAllocator object - handle to Vulkan device etc.
///
/// It might be useful if you want to keep just the VmaAllocator handle and fetch other required handles to VkPhysicalDevice, VkDevice etc. every time using this function.
pub extern fn vmaGetAllocatorInfo(
    allocator: Allocator,
    p_allocator_info: *AllocatorInfo,
) void;

/// Retrieves information about current memory usage and budget for all memory heaps.
pub extern fn vmaGetHeapBudgets(
    allocator: Allocator,
    p_budgets: *Budget,
) void;

/// PhysicalDeviceMemoryProperties are fetched from physicalDevice by the allocator. You can access it here, without fetching it again on your own.
pub extern fn vmaGetMemoryProperties(
    allocator: Allocator,
    pp_physical_device_memory_properties: ?*const vk.PhysicalDeviceMemoryProperties,
) void;

/// Given Memory Type Index, returns Property Flags of this memory type.
///
/// This is just a convenience function. Same information can be obtained using vmaGetMemoryProperties().
pub extern fn vmaGetMemoryTypeProperties(
    allocator: Allocator,
    memory_type_index: u32,
    p_flags: *vk.MemoryPropertyFlags,
) void;

/// Given an allocation, returns Win32 handle that may be imported by other processes or APIs.
pub extern fn vmaGetMemoryWin32Handle(
    allocator: Allocator,
    allocation: Allocation,
    hTargetProcess: HANDLE,
    pHandle: ?*HANDLE,
) vk.Result;

/// PhysicalDeviceProperties are fetched from physicalDevice by the allocator. You can access it here, without fetching it again on your own.
pub extern fn vmaGetPhysicalDeviceProperties(
    allocator: Allocator,
    pp_physical_device_properties: *const vk.PhysicalDeviceProperties,
) void;

/// Maps memory represented by given allocation and returns pointer to it.
pub extern fn vmaMapMemory(
    allocator: Allocator,
    allocation: Allocation,
    pp_data: ?[*]*anyopaque,
) vk.Result;

/// Unmaps memory represented by given allocation, mapped previously using vmaMapMemory().
pub extern fn vmaUnmapMemory(
    allocator: Allocator,
    allocation: Allocation,
) void;

/// Allocates new virtual allocation inside given VmaVirtualBlock.
///
/// If the allocation fails due to not enough free space available, VK_ERROR_OUT_OF_DEVICE_MEMORY is returned (despite the function doesn't ever allocate actual GPU memory). pAllocation is then set to VK_NULL_HANDLE and pOffset, if not null, it set to UINT64_MAX.
pub extern fn vmaVirtualAllocate(
    virtual_block: VirtualBlock,
    p_create_info: *const VirtualAllocationCreateInfo,
    p_allocation: ?*VirtualAllocation,
    p_offset: ?*vk.DeviceSize,
) vk.Result;

/// Frees virtual allocation inside given VmaVirtualBlock.
///
/// It is correct to call this function with allocation == VK_NULL_HANDLE - it does nothing.
pub extern fn vmaVirtualFree(
    virtual_block: VirtualBlock,
    allocation: ?VirtualAllocation,
) void;

/// Flushes memory of given allocation.
pub extern fn vmaFlushAllocation(
    allocator: Allocator,
    allocation: Allocation,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
) vk.Result;

/// Invalidates memory of given allocation.
pub extern fn vmaInvalidateAllocation(
    allocator: Allocator,
    allocation: Allocation,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
) vk.Result;

/// Flushes memory of given set of allocations.
pub extern fn vmaFlushAllocations(
    allocator: Allocator,
    allocation_count: u32,
    allocations: ?*const Allocation,
    offsets: ?*const vk.DeviceSize,
    sizes: ?*const vk.DeviceSize,
) vk.Result;

/// Invalidates memory of given set of allocations.
pub extern fn vmaInvalidateAllocations(
    allocator: Allocator,
    allocation_count: u32,
    allocations: ?*const Allocation,
    offsets: ?*const vk.DeviceSize,
    sizes: ?*const vk.DeviceSize,
) vk.Result;

/// Returns true of the VmaVirtualBlock is empty - contains 0 virtual allocations and has all its space available for new allocations.
pub extern fn vmaIsVirtualBlockEmpty(
    virtual_block: VirtualBlock,
) vk.Bool32;

/// Maps the allocation temporarily if needed, copies data from specified host pointer to it, and flushes the memory from the host caches if needed.
pub extern fn vmaCopyMemoryToAllocation(
    allocator: Allocator,
    p_src_host_pointer: *const anyopaque,
    dst_allocation: Allocation,
    dst_allocation_local_offset: vk.DeviceSize,
    size: vk.DeviceSize,
) vk.Result;

/// Invalidates memory in the host caches if needed, maps the allocation temporarily if needed, and copies data from it to a specified host pointer.
pub extern fn vmaCopyAllocationToMemory(
    allocator: Allocator,
    src_allocation: Allocation,
    src_allocation_local_offset: vk.DeviceSize,
    p_dst_host_pointer: *anyopaque,
    size: vk.DeviceSize,
) vk.Result;

/// Begins defragmentation process.
pub extern fn vmaBeginDefragmentation(
    allocator: Allocator,
    p_info: *const DefragmentationInfo,
    p_context: ?*DefragmentationContext,
) vk.Result;

/// Ends defragmentation process.
pub extern fn vmaEndDefragmentation(
    allocator: Allocator,
    context: DefragmentationContext,
    p_stats: ?*DefragmentationStats,
) void;

/// Starts single defragmentation pass.
pub extern fn vmaBeginDefragmentationPass(
    allocator: Allocator,
    context: DefragmentationContext,
    p_pass_info: *DefragmentationPassMoveInfo,
) vk.Result;

/// Ends single defragmentation pass.
pub extern fn vmaEndDefragmentationPass(
    allocator: Allocator,
    context: DefragmentationContext,
    p_pass_info: *DefragmentationPassMoveInfo,
) vk.Result;

/// Binds buffer to allocation.
pub extern fn vmaBindBufferMemory(
    allocator: Allocator,
    allocation: Allocation,
    buffer: vk.Buffer,
) vk.Result;

/// Binds buffer to allocation with additional parameters.
pub extern fn vmaBindBufferMemory2(
    allocator: Allocator,
    allocation: Allocation,
    allocation_local_offset: vk.DeviceSize,
    buffer: vk.Buffer,
    p_next: ?*const anyopaque, // TODO: Check `const void *(VkBindBufferMemoryInfoKHR) pNext`
) vk.Result;

/// Binds image to allocation.
pub extern fn vmaBindImageMemory(
    allocator: Allocator,
    allocation: Allocation,
    image: vk.Image,
) vk.Result;

/// Binds image to allocation with additional parameters.
pub extern fn vmaBindImageMemory2(
    allocator: Allocator,
    allocation: Allocation,
    allocation_local_offset: vk.DeviceSize,
    image: vk.Image,
    p_next: ?*const anyopaque, // TODO: Check `const void *(VkBindImageMemoryInfoKHR) pNext`
) vk.Result;

/// Builds and returns statistics as a null-terminated string in JSON format.
pub extern fn vmaBuildStatsString(
    allocator: Allocator,
    pp_stats_string: ?[*][*:0]u8,
    detailed_map: vk.Bool32,
) void;

/// Builds and returns a null-terminated string in JSON format with information about given VmaVirtualBlock.
pub extern fn vmaBuildVirtualBlockStatsString(
    virtual_block: VirtualBlock,
    pp_stats_string: ?[*][*:0]u8,
    detailed_map: vk.Bool32,
) void;

/// Retrieves detailed statistics of existing VmaPool object.
pub extern fn vmaCalculatePoolStatistics(
    allocator: Allocator,
    pool: Pool,
    pPoolStats: *DetailedStatistics,
) void;

/// Retrieves statistics from current state of the Allocator.
///
/// This function is called "calculate" not "get" because it has to traverse all internal data structures, so it may be quite slow. Use it for debugging purposes. For faster but more brief statistics suitable to be called every frame or every allocation, use vmaGetHeapBudgets().
///
/// Note that when using allocator from multiple threads, returned information may immediately become outdated.
pub extern fn vmaCalculateStatistics(
    allocator: Allocator,
    p_stats: *TotalStatistics,
) void;

/// Calculates and returns detailed statistics about virtual allocations and memory usage in given VmaVirtualBlock.
///
/// This function is slow to call. Use for debugging purposes. For less detailed statistics, see vmaGetVirtualBlockStatistics().
pub extern fn vmaCalculateVirtualBlockStatistics(
    virtual_block: VirtualBlock,
    p_stats: *DetailedStatistics,
) void;

/// Checks magic number in margins around all allocations in given memory types (in both default and custom pools) in search for corruptions.
pub extern fn vmaCheckCorruption(
    allocator: Allocator,
    memory_type_bits: u32,
) vk.Result;

/// Creates a new VkBuffer, allocates and binds memory for it.
pub extern fn vmaCreateBuffer(
    allocator: Allocator,
    p_buffer_create_info: *const vk.BufferCreateInfo,
    p_allocation_create_info: *const AllocationCreateInfo,
    p_buffer: ?*vk.Buffer,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Creates a buffer with additional minimum alignment.
pub extern fn vmaCreateBufferWithAlignment(
    allocator: Allocator,
    p_buffer_create_info: *const vk.BufferCreateInfo,
    p_allocation_create_info: *const AllocationCreateInfo,
    min_alignment: vk.DeviceSize,
    p_buffer: ?*vk.Buffer,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Creates a new VkBuffer, binds already created memory for it.
pub extern fn vmaCreateAliasingBuffer(
    allocator: Allocator,
    allocation: Allocation,
    p_buffer_create_info: *const vk.BufferCreateInfo,
    p_buffer: ?*vk.Buffer,
) vk.Result;

/// Creates a new VkBuffer, binds already created memory for it.
pub extern fn vmaCreateAliasingBuffer2(
    allocator: Allocator,
    allocation: Allocation,
    allocation_local_offset: vk.DeviceSize,
    p_buffer_create_info: *const vk.BufferCreateInfo,
    p_buffer: ?*vk.Buffer,
) vk.Result;

/// Destroys Vulkan buffer and frees allocated memory.
pub extern fn vmaDestroyBuffer(
    allocator: Allocator,
    buffer: ?vk.Buffer,
    allocation: ?Allocation,
) void;

/// Function similar to vmaCreateBuffer().
pub extern fn vmaCreateImage(
    allocator: Allocator,
    p_image_create_info: *const vk.ImageCreateInfo,
    p_allocation_create_info: *const AllocationCreateInfo,
    p_image: ?*vk.Image,
    p_allocation: ?*Allocation,
    p_allocation_info: ?*AllocationInfo,
) vk.Result;

/// Function similar to vmaCreateAliasingBuffer() but for images.
pub extern fn vmaCreateAliasingImage(
    allocator: Allocator,
    allocation: Allocation,
    p_image_create_info: *const vk.ImageCreateInfo,
    p_image: ?*vk.Image,
) vk.Result;

/// Function similar to vmaCreateAliasingBuffer2() but for images.
pub extern fn vmaCreateAliasingImage2(
    allocator: Allocator,
    allocation: Allocation,
    allocation_local_offset: vk.DeviceSize,
    p_image_create_info: *const vk.ImageCreateInfo,
    p_image: ?*vk.Image,
) vk.Result;

/// Creates VmaAllocator object.
pub extern fn vmaCreateAllocator(
    p_create_info: *const AllocatorCreateInfo,
    p_allocator: *Allocator,
) vk.Result;

/// Destroys Vulkan image and frees allocated memory.
pub extern fn vmaDestroyImage(
    allocator: Allocator,
    image: ?vk.Image,
    allocation: ?Allocation,
) void;

// Typdef functions -----------------------------------------------------------
// ----------------------------------------------------------------------------
pub const PfnVmaAllocateDeviceMemoryFunction = ?*const fn (
    allocator: Allocator,
    memory_type: u32,
    memory: vk.DeviceMemory,
    size: vk.DeviceSize,
    p_user_data: ?*anyopaque,
) callconv(vulkan_call_conv) void;

pub const PfnVmaCheckDefragmentationBreakFunction = ?*const fn (
    p_user_data: ?*anyopaque,
) callconv(vulkan_call_conv) vk.Bool32;

pub const PfnVmaFreeDeviceMemoryFunction = ?*const fn (
    allocator: Allocator,
    memory_type: u32,
    memory: vk.DeviceMemory,
    size: vk.DeviceSize,
    p_user_data: ?*anyopaque,
) callconv(vulkan_call_conv) void;

pub const HANDLE = if (@hasDecl(root, "HANDLE")) root.HANDLE else std.os.windows.HANDLE;

const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

const vk = @import("vulkan");

const Allocation = @import("./structs.zig").Allocation;
const AllocationCreateInfo = @import("./structs.zig").AllocationCreateInfo;
const AllocationInfo = @import("./structs.zig").AllocationInfo;
const AllocationInfo2 = @import("./structs.zig").AllocationInfo2;
const Allocator = @import("./structs.zig").Allocator;
const AllocatorCreateInfo = @import("./structs.zig").AllocatorCreateInfo;
const AllocatorInfo = @import("./structs.zig").AllocatorInfo;
const Budget = @import("./structs.zig").Budget;
const DefragmentationContext = @import("./structs.zig").DefragmentationContext;
const DefragmentationInfo = @import("./structs.zig").DefragmentationInfo;
const DefragmentationPassMoveInfo = @import("./structs.zig").DefragmentationPassMoveInfo;
const DefragmentationStats = @import("./structs.zig").DefragmentationStats;
const DetailedStatistics = @import("./structs.zig").DetailedStatistics;
const Pool = @import("./structs.zig").Pool;
const PoolCreateInfo = @import("./structs.zig").PoolCreateInfo;
const Statistics = @import("./structs.zig").Statistics;
const TotalStatistics = @import("./structs.zig").TotalStatistics;
const VirtualAllocation = @import("./structs.zig").VirtualAllocation;
const VirtualAllocationCreateInfo = @import("./structs.zig").VirtualAllocationCreateInfo;
const VirtualAllocationInfo = @import("./structs.zig").VirtualAllocationInfo;
const VirtualBlock = @import("./structs.zig").VirtualBlock;
const VirtualBlockCreateInfo = @import("./structs.zig").VirtualBlockCreateInfo;
const VulkanFunctions = @import("./structs.zig").VulkanFunctions;
