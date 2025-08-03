pub const c = @import("./c.zig");

pub const VulkanMemoryAllocator = @import("./allocator.zig").VulkanMemoryAllocator;
pub const VirtualBlock = @import("./virtual_block.zig").VirtualBlock;

// Re-export Handles and Struct for ease of access.

pub const Pool = c.Pool;
pub const Allocation = c.Allocation;
pub const DefragmentationContext = c.DefragmentationContext;
pub const VirtualAllocation = c.VirtualAllocation;

pub const AllocationCreateInfo = c.AllocationCreateInfo;
pub const AllocationInfo = c.AllocationInfo;
pub const AllocationInfo2 = c.AllocationInfo2;
pub const AllocatorCreateInfo = c.AllocatorCreateInfo;
pub const AllocatorInfo = c.AllocatorInfo;
pub const Budget = c.Budget;
pub const DefragmentationInfo = c.DefragmentationInfo;
pub const DefragmentationMove = c.DefragmentationMove;
pub const DefragmentationPassMoveInfo = c.DefragmentationPassMoveInfo;
pub const DefragmentationStats = c.DefragmentationStats;
pub const DetailedStatistics = c.DetailedStatistics;
pub const DeviceMemoryCallbacks = c.DeviceMemoryCallbacks;
pub const PoolCreateInfo = c.PoolCreateInfo;
pub const Statistics = c.Statistics;
pub const TotalStatistics = c.TotalStatistics;
pub const VirtualAllocationCreateInfo = c.VirtualAllocationCreateInfo;
pub const VirtualAllocationInfo = c.VirtualAllocationInfo;
pub const VirtualBlockCreateInfo = c.VirtualBlockCreateInfo;
pub const VulkanFunctions = c.VulkanFunctions;
