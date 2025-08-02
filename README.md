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
| `` | `` |

# Extra info

> [!NOTE]
> Lots of inspiration taken form [https://github.com/damemay/vk-mem-alloc-zig](https://github.com/damemay/vk-mem-alloc-zig).

# TODO
- [x] Finish `C` API.
- [ ] Write a wrapper over the functionality.
- [ ] Add example.
- [ ] Improve documentation.
