pub fn FlagsMixin(comptime FlagsType: type) type {
    return struct {
        pub const IntType = @typeInfo(FlagsType).@"struct".backing_integer.?;

        pub fn toInt(self: FlagsType) IntType {
            return @bitCast(self);
        }

        pub fn fromInt(flags: IntType) FlagsType {
            return @bitCast(flags);
        }

        pub fn merge(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) | toInt(rhs));
        }

        pub fn intersect(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) & toInt(rhs));
        }

        pub fn complement(self: FlagsType) FlagsType {
            return fromInt(~toInt(self));
        }

        pub fn subtract(lhs: FlagsType, rhs: FlagsType) FlagsType {
            return fromInt(toInt(lhs) & toInt(rhs.complement()));
        }

        pub fn contains(lhs: FlagsType, rhs: FlagsType) bool {
            return toInt(intersect(lhs, rhs)) == toInt(rhs);
        }
    };
}

fn FlagFormatMixin(comptime FlagsType: type) type {
    return struct {
        pub fn format(
            self: FlagsType,
            comptime _: []const u8,
            _: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            try writer.writeAll(@typeName(FlagsType) ++ "{");
            var first = true;

            @setEvalBranchQuota(100_000);
            inline for (comptime std.meta.fieldNames(FlagsType)) |name| {
                if (name[0] == '_') continue;

                if (@field(self, name)) {
                    if (first) {
                        try writer.writeAll(" ." ++ name);
                        first = false;
                    } else {
                        try writer.writeAll(", ." ++ name);
                    }
                }
            }

            if (!first) try writer.writeAll(" ");

            try writer.writeAll("}");
        }
    };
}

pub const Flags = u32;

/// Intended usage of the allocated memory.
pub const MemoryUsage = enum(i32) {
    /// No intended memory usage specified.
    /// Use other members of `VmaAllocationCreateInfo` to specify your requirements.
    unknown = 0,
    /// ## DEPRECATED
    /// **Obsolete, preserved for backward compatibility.**
    ///
    /// Prefers `VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT`.
    gpu_only = 1,
    /// ## DEPRECATED
    /// **Obsolete, preserved for backward compatibility.**
    ///
    /// Guarantees `VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT` and `VK_MEMORY_PROPERTY_HOST_COHERENT_BIT`.
    cpu_only = 2,
    /// ## DEPRECATED
    /// **Obsolete, preserved for backward compatibility.**
    ///
    /// Guarantees `VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT`, prefers `VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT`.
    cpu_to_gpu = 3,
    /// ## DEPRECATED
    /// **Obsolete, preserved for backward compatibility.**
    ///
    /// Guarantees `VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT`, prefers `VK_MEMORY_PROPERTY_HOST_CACHED_BIT`.
    gpu_to_cpu = 4,
    /// ## DEPRECATED
    /// **Obsolete, preserved for backward compatibility.**
    ///
    /// Prefers not `VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT`.
    cpu_copy = 5,
    gpu_lazily_allocated = 6,
    auto = 7,
    auto_prefer_device = 8,
    auto_prefer_host = 9,
    _,
    // max_enum = 0x7FFFFFFF,
};

/// Operation performed on single defragmentation move.
/// See structure `VmaDefragmentationMove`*(Parameters of new VmaAllocation.)*.
pub const DefragmentationMoveOperation = enum(i32) {
    /// Buffer/image has been recreated at `dstTmpAllocation`, data has been copied,
    /// old buffer/image has been destroyed.
    /// `srcAllocation` should be changed to point to the new place.
    /// This is the default value set by `vmaBeginDefragmentationPass()`*(Starts single defragmentation pass.)*.
    copy = 0,
    /// Set this value if you cannot move the allocation.
    /// New place reserved at `dstTmpAllocation` will be freed.
    /// `srcAllocation` will remain unchanged.
    ignore = 1,
    /// Set this value if you decide to abandon the allocation and you destroyed the buffer/image.
    /// New place reserved at `dstTmpAllocation` will be freed, along with `srcAllocation`,
    /// which will be destroyed.
    destroy = 2,
    _,
};

// TODO: Find fix for alias and this `VMA_ALLOCATION_CREATE_STRATEGY_MASK` value.
/// Flags to be passed as `VmaAllocationCreateInfo::flags`*(Use VmaAllocationCreateFlagBits enum.)*.
pub const AllocationCreateFlags = packed struct(Flags) {
    dedicated_memory_bit: bool = false, // 0x00000001
    never_allocate_bit: bool = false, // 0x00000002
    mapped_bit: bool = false, // 0x00000004
    _reserved_bit_3: bool = false,
    _reserved_bit_4: bool = false,
    user_data_copy_string_bit: bool = false, // 0x00000020
    upper_address_bit: bool = false, // 0x00000040
    dont_bind_bit: bool = false, // 0x00000080
    within_budget_bit: bool = false, // 0x00000100
    can_alias_bit: bool = false, // 0x00000200
    host_access_sequential_write_bit: bool = false, // 0x00000400
    host_access_random_bit: bool = false, // 0x00000800
    host_access_allow_transfer_instead_bit: bool = false, // 0x00001000
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    /// strategy_best_fit_bit
    strategy_min_memory_bit: bool = false, // 0x00010000
    /// strategy_first_fit_bit
    strategy_min_time_bit: bool = false, // 0x00020000
    strategy_min_offset_bit: bool = false, // 0x00040000
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    pub const toInt = FlagsMixin(AllocationCreateFlags).toInt;
    pub const fromInt = FlagsMixin(AllocationCreateFlags).fromInt;
    pub const merge = FlagsMixin(AllocationCreateFlags).merge;
    pub const intersect = FlagsMixin(AllocationCreateFlags).intersect;
    pub const complement = FlagsMixin(AllocationCreateFlags).complement;
    pub const subtract = FlagsMixin(AllocationCreateFlags).subtract;
    pub const contains = FlagsMixin(AllocationCreateFlags).contains;
    pub const format = FlagFormatMixin(AllocationCreateFlags).format;
};

pub const AllocatorCreateFlags = packed struct(Flags) {
    externaly_synchronized_bit: bool = false,
    dedicated_allocation_bit_khr: bool = false,
    bind_memory2_bit_khr: bool = false,
    memory_budget_bit_ext: bool = false,
    device_coherent_memory_bit_amd: bool = false,
    buffer_device_address_bit: bool = false,
    memory_priority_bit_ext: bool = false,
    maintenance4_khr: bool = false,
    maintenance5_khr: bool = false,
    external_memory_win32_bit_khr: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    _reserved_bit_16: bool = false,
    _reserved_bit_17: bool = false,
    _reserved_bit_18: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    pub const toInt = FlagsMixin(AllocatorCreateFlags).toInt;
    pub const fromInt = FlagsMixin(AllocatorCreateFlags).fromInt;
    pub const merge = FlagsMixin(AllocatorCreateFlags).merge;
    pub const intersect = FlagsMixin(AllocatorCreateFlags).intersect;
    pub const complement = FlagsMixin(AllocatorCreateFlags).complement;
    pub const subtract = FlagsMixin(AllocatorCreateFlags).subtract;
    pub const contains = FlagsMixin(AllocatorCreateFlags).contains;
    pub const format = FlagFormatMixin(AllocatorCreateFlags).format;
};

pub const PoolCreateFlags = packed struct(Flags) {
    _reserved_bit_0: bool = false,
    ignore_buffer_image_granularity_bit: bool = false,
    linear_algorithm_bit: bool = false,
    _reserved_bit_3: bool = false,
    _reserved_bit_4: bool = false,
    _reserved_bit_5: bool = false,
    _reserved_bit_6: bool = false,
    _reserved_bit_7: bool = false,
    _reserved_bit_8: bool = false,
    _reserved_bit_9: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    _reserved_bit_16: bool = false,
    _reserved_bit_17: bool = false,
    _reserved_bit_18: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    pub const toInt = FlagsMixin(PoolCreateFlags).toInt;
    pub const fromInt = FlagsMixin(PoolCreateFlags).fromInt;
    pub const merge = FlagsMixin(PoolCreateFlags).merge;
    pub const intersect = FlagsMixin(PoolCreateFlags).intersect;
    pub const complement = FlagsMixin(PoolCreateFlags).complement;
    pub const subtract = FlagsMixin(PoolCreateFlags).subtract;
    pub const contains = FlagsMixin(PoolCreateFlags).contains;
    pub const format = FlagFormatMixin(PoolCreateFlags).format;
};

pub const DefragmentationFlags = packed struct(Flags) {
    _reserved_bit_0: bool = false,
    _reserved_bit_1: bool = false,
    _reserved_bit_2: bool = false,
    _reserved_bit_3: bool = false,
    _reserved_bit_4: bool = false,
    _reserved_bit_5: bool = false,
    _reserved_bit_6: bool = false,
    _reserved_bit_7: bool = false,
    _reserved_bit_8: bool = false,
    _reserved_bit_9: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    _reserved_bit_16: bool = false,
    _reserved_bit_17: bool = false,
    _reserved_bit_18: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    algorithm_fast_bit: bool = false,
    algorithm_balanced_bit: bool = false,
    algorithm_full_bit: bool = false,
    algorithm_extensive_bit: bool = false,

    pub const toInt = FlagsMixin(DefragmentationFlags).toInt;
    pub const fromInt = FlagsMixin(DefragmentationFlags).fromInt;
    pub const merge = FlagsMixin(DefragmentationFlags).merge;
    pub const intersect = FlagsMixin(DefragmentationFlags).intersect;
    pub const complement = FlagsMixin(DefragmentationFlags).complement;
    pub const subtract = FlagsMixin(DefragmentationFlags).subtract;
    pub const contains = FlagsMixin(DefragmentationFlags).contains;
    pub const format = FlagFormatMixin(DefragmentationFlags).format;
};

pub const VirtualBlockCreateFlags = packed struct(Flags) {
    linear_algorithm_bit: bool = false,
    _reserved_bit_1: bool = false,
    _reserved_bit_2: bool = false,
    _reserved_bit_3: bool = false,
    _reserved_bit_4: bool = false,
    _reserved_bit_5: bool = false,
    _reserved_bit_6: bool = false,
    _reserved_bit_7: bool = false,
    _reserved_bit_8: bool = false,
    _reserved_bit_9: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    _reserved_bit_16: bool = false,
    _reserved_bit_17: bool = false,
    _reserved_bit_18: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    pub const toInt = FlagsMixin(VirtualBlockCreateFlags).toInt;
    pub const fromInt = FlagsMixin(VirtualBlockCreateFlags).fromInt;
    pub const merge = FlagsMixin(VirtualBlockCreateFlags).merge;
    pub const intersect = FlagsMixin(VirtualBlockCreateFlags).intersect;
    pub const complement = FlagsMixin(VirtualBlockCreateFlags).complement;
    pub const subtract = FlagsMixin(VirtualBlockCreateFlags).subtract;
    pub const contains = FlagsMixin(VirtualBlockCreateFlags).contains;
    pub const format = FlagFormatMixin(VirtualBlockCreateFlags).format;
};

pub const VirtualAllocationCreateFlags = packed struct(Flags) {
    _reserved_bit_0: bool = false,
    _reserved_bit_1: bool = false,
    _reserved_bit_2: bool = false,
    _reserved_bit_3: bool = false,
    _reserved_bit_4: bool = false,
    _reserved_bit_5: bool = false,
    upper_address_bit: bool = false,
    _reserved_bit_7: bool = false,
    _reserved_bit_8: bool = false,
    _reserved_bit_9: bool = false,
    _reserved_bit_10: bool = false,
    _reserved_bit_11: bool = false,
    _reserved_bit_12: bool = false,
    _reserved_bit_13: bool = false,
    _reserved_bit_14: bool = false,
    _reserved_bit_15: bool = false,
    strategy_min_memory_bit: bool = false,
    strategy_min_time_bit: bool = false,
    strategy_min_offset_bit: bool = false,
    _reserved_bit_19: bool = false,
    _reserved_bit_20: bool = false,
    _reserved_bit_21: bool = false,
    _reserved_bit_22: bool = false,
    _reserved_bit_23: bool = false,
    _reserved_bit_24: bool = false,
    _reserved_bit_25: bool = false,
    _reserved_bit_26: bool = false,
    _reserved_bit_27: bool = false,
    _reserved_bit_28: bool = false,
    _reserved_bit_29: bool = false,
    _reserved_bit_30: bool = false,
    _reserved_bit_31: bool = false,

    pub const toInt = FlagsMixin(VirtualAllocationCreateFlags).toInt;
    pub const fromInt = FlagsMixin(VirtualAllocationCreateFlags).fromInt;
    pub const merge = FlagsMixin(VirtualAllocationCreateFlags).merge;
    pub const intersect = FlagsMixin(VirtualAllocationCreateFlags).intersect;
    pub const complement = FlagsMixin(VirtualAllocationCreateFlags).complement;
    pub const subtract = FlagsMixin(VirtualAllocationCreateFlags).subtract;
    pub const contains = FlagsMixin(VirtualAllocationCreateFlags).contains;
    pub const format = FlagFormatMixin(VirtualAllocationCreateFlags).format;
};

const std = @import("std");
