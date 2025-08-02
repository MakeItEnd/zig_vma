Zig Wrapped - Vulkan Memory Allocator
=====================================

> [!WARNING]
> Work In Progress.

Using VMA version 3.3.0

# Synopsis

This is a ziggyfied wrapper over [VulkanMemoryAllocator](https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator) that also exposes the `C` API.

> [!NOTE]
> This library tightly coupled with [Snektron/vulkan-zig](https://github.com/Snektron/vulkan-zig) library. (This [MAY](https://datatracker.ietf.org/doc/html/rfc2119#section-5) change in the future)

# How to install

 - Add the repo to your `build.zig.zon` file with:
```sh
zig fetch --save git+https://github.com/MakeItEnd/zig_vma#main
```

 - Add this to your `build.zig`:
```zig
const zig_vma_dep = b.dependency("zig_vma", .{
    .target = target,
    .optimize = optimize,
});
const zig_vma = zig_vma_dep.module("zig_vma");

// IMPORTANT: Add vulkan-zig import to zig_vma!
// --- vulkan-zig
const vulkan = b.dependency("vulkan", .{
    .registry = b.path("./vk.xml"),
}).module("vulkan-zig");
// --- vulkan-zig

zig_vma.addImport("vulkan", vulkan);

// ...

exe.root_module.addImport("zig_vma", zig_vma);
```

# Details

Most wrapped methods for equivalent `C` functions that would return `vk.Result` will convert that to a zig error if typically only one variant of it is returned and its a clear error. It keeps the return type when multiple variants of `vk.Result` are returned that each denote a specific problem with the users vulkan code, or the VMA documentation doesn't specify the variants.

For the `VulkanMemoryAllocator` wrapper all `C` functions were renamed to:

| Old Name | New Name |
|:---------|:---------|
| **General Functions** | |
| `vmaCreateAllocator` | `init` |
| `vmaDestroyAllocator` | `deinit` |
| `vmaImportVulkanFunctionsFromVolk` | `importVulkanFunctionsFromVolk` |
| `vmaCheckCorruption` | `checkCorruption` |
| `vmaGetAllocatorInfo` | `getInfo` |
| `vmaGetAllocatorInfo` | `getHeapBudgets` |
| `vmaGetPhysicalDeviceProperties` | `getPhysicalDeviceProperties` |
| `vmaSetCurrentFrameIndex` | `setCurrentFrameIndex` |
|||
| `vmaBuildStatsString` | `statsBuildString` |
| `vmaFreeStatsString` | `statsFreeString` |
| `vmaCalculateStatistics` | `calculateStatistics` |
|||
| `vmaBeginDefragmentation` | `defragmentationBegin` |
| `vmaEndDefragmentation` | `defragmentationEnd` |
| `vmaBeginDefragmentationPass` | `defragmentationPassBegin` |
| `vmaEndDefragmentationPass` | `defragmentationPassEnd` |
|||
| `vmaAllocateMemory` | `memoryAllocate` |
| `vmaAllocateMemoryForBuffer` | `memoryAllocateForBuffer` |
| `vmaAllocateMemoryForImage` | `memoryAllocateForImage` |
| `vmaAllocateMemoryPages` | `memoryPagesAllocate` |
| `vmaFreeMemory` | `memoryFree` |
| `vmaFreeMemoryPages` | `memoryPagesFree` |
| `vmaFindMemoryTypeIndex` | `memoryFindTypeIndex` |
| `vmaGetMemoryProperties` | `memoryGetProperties` |
| `vmaGetMemoryTypeProperties` | `memoryGetTypeProperties` |
| `vmaMapMemory` | `memoryMap` |
| `vmaUnmapMemory` | `memoryUnmap` |
| `vmaCopyMemoryToAllocation` | `memoryCopyToAllocation` |
| `vmaGetMemoryWin32Handle` | `memoryGetWin32Handle` |
|||
| `vmaFlushAllocation` | `allocationFlush` |
| `vmaFlushAllocations` | `allocationsFlush` |
| `vmaGetAllocationInfo` | `allocationGetInfo` |
| `vmaGetAllocationInfo2` | `allocationGetInfo2` |
| `vmaGetAllocationMemoryProperties` | `allocationGetMemoryProperties` |
| `vmaInvalidateAllocation` | `allocationInvalidate` |
| `vmaInvalidateAllocations` | `allocationsInvalidate` |
| `vmaSetAllocationName` | `allocationSetName` |
| `vmaSetAllocationUserData` | `allocationSetUserData` |
| `vmaCopyAllocationToMemory` | `allocationCopyToMemory` |
|||
| `vmaCreatePool` | `poolCreate` |
| `vmaDestroyPool` | `poolDestroy` |
| `vmaGetPoolName` | `poolNameGet` |
| `vmaSetPoolName` | `poolNameSet` |
| `vmaCheckPoolCorruption` | `poolCheckCorruption` |
| `vmaGetPoolStatistics` | `poolGetStatistics` |
| `vmaCalculatePoolStatistics` | `poolCalculateStatistics` |
|||
| `vmaCreateBuffer` | `` |
| `vmaCreateBufferWithAlignment` | `` |
| `vmaCreateAliasingBuffer` | `` |
| `vmaCreateAliasingBuffer2` | `` |
| `vmaDestroyBuffer` | `` |
| `vmaBindBufferMemory` | `` |
| `vmaBindBufferMemory2` | `` |
| `vmaFindMemoryTypeIndexForBufferInfo` | `` |
|||
| `vmaCreateImage` | `` |
| `vmaCreateAliasingImage` | `` |
| `vmaCreateAliasingImage2` | `` |
| `vmaDestroyImage` | `` |
| `vmaBindImageMemory` | `` |
| `vmaBindImageMemory2` | `` |
| `vmaFindMemoryTypeIndexForImageInfo` | `` |

For the `VirtualBlock` wrapper all `C` functions were renamed to:

| Old Name | New Name |
|:---------|:---------|
| `vmaCreateVirtualBlock` | `init` |
| `vmaDestroyVirtualBlock` | `deinit` |
| `vmaVirtualAllocate` | `allocate` |
| `vmaVirtualFree` | `free` |
| `vmaClearVirtualBlock` | `clear` |
| `vmaIsVirtualBlockEmpty` | `isEmpty` |
| `vmaGetVirtualBlockStatistics` | `getStatistics` |
| `vmaBuildVirtualBlockStatsString` | `statsStringBuild` |
| `vmaFreeVirtualBlockStatsString` | `statsStringFree` |
| `vmaCalculateVirtualBlockStatistics` | `calculateStatistics` |
| `vmaGetVirtualAllocationInfo` | `allocationGetInfo` |
| `vmaSetVirtualAllocationUserData` | `allocationSetUserData` |

# Extra info

> [!NOTE]
> Lots of inspiration taken form [https://github.com/damemay/vk-mem-alloc-zig](https://github.com/damemay/vk-mem-alloc-zig).

# TODO
- [x] Finish `C` API.
- [ ] Write a wrapper over the functionality.
- [ ] Add example.
- [ ] Improve documentation.
- [ ] Convert more `vk.Result` returns form wrapped functions to a more `zig`-like response.
