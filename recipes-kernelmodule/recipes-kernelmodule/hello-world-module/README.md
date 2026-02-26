# Hello World Kernel Module

A simple kernel module recipe for Yocto that demonstrates how to build, install, and auto-load a basic kernel module.

## Overview

This recipe creates a kernel module that:
- Prints "Hello World from kernel module!" when loaded
- Prints "Goodbye from kernel module!" when unloaded
- Auto-loads at system boot time

## Files

```
hello-world-module/
├── hello-world-module.bb      # BitBake recipe
└── files/
    ├── hello_world.c          # Kernel module source code
    └── Makefile               # Build instructions
```

## Installation Location

The compiled kernel module is installed at:
```
/lib/modules/<kernel-version>/updates/hello_world.ko
```

For example:
```
/lib/modules/6.6.111-yocto-standard/updates/hello_world.ko
```

### Why `updates/` and not `extra/`?

Out-of-tree kernel modules can be installed in different subdirectories:

#### `/lib/modules/<kernel-version>/updates/`
- **Default for most Yocto recipes** using `inherit module`
- Used by the standard `modules_install` Makefile target
- Has **highest priority** in module loading (overrides in-tree and extra modules)
- Purpose: For updated/replacement versions of existing kernel modules
- This is where **this recipe installs** the module

#### `/lib/modules/<kernel-version>/extra/`
- Used for additional/supplementary out-of-tree modules
- **Lower priority** than `updates/` but higher than in-tree kernel modules
- Typically used when explicitly specified in the Makefile or recipe
- Purpose: For completely new modules that don't replace anything

#### `/lib/modules/<kernel-version>/kernel/`
- Reserved for **in-tree kernel modules** (built with the kernel source)
- Lowest priority for module loading
- Not used for out-of-tree modules built by recipes

#### Module Search Order Priority:
When you run `modprobe module_name`, the system searches in this order:
1. **`updates/`** (highest priority - overrides everything)
2. **`extra/`** (medium priority)
3. **`kernel/`** (lowest priority - built-in kernel modules)

### Factors Determining Installation Directory:

**1. Makefile `INSTALL_MOD_DIR` variable:**
```makefile
# In your module's Makefile:
INSTALL_MOD_DIR := extra    # Installs to extra/
# or
INSTALL_MOD_DIR := updates  # Installs to updates/
```

**2. BitBake recipe configuration:**
```bitbake
# Default behavior (updates/)
do_install() {
    oe_runmake modules_install INSTALL_MOD_PATH=${D}
}

# To install in extra/ instead:
do_install() {
    oe_runmake modules_install INSTALL_MOD_PATH=${D} INSTALL_MOD_DIR=extra
}
```

**3. Kernel's `Makefile.modpost` default:**
- If `INSTALL_MOD_DIR` is not specified, kernel defaults to `extra/`
- However, Yocto's `module.bbclass` may override this to use `updates/`

### For This Recipe:

This `hello-world-module` recipe:
- Uses `inherit module` which includes Yocto's module build class
- Calls standard `modules_install` without specifying `INSTALL_MOD_DIR`
- Results in installation to **`updates/`** directory
- This means it has the **highest priority** if there were conflicting module names

## Auto-Load Configuration

The recipe includes `KERNEL_MODULE_AUTOLOAD += "hello_world"` which automatically:
- Creates `/etc/modules-load.d/hello_world.conf` with the module name
- Loads the module at boot via `systemd-modules-load.service`

## Building

### Build the module only:
```bash
cd /path/to/yocto-workspace/poky/build
bitbake hello-world-module
```

### Rebuild from clean state:
```bash
bitbake hello-world-module -c cleansstate
bitbake hello-world-module
```

### Include in your image:
Add to your image recipe (e.g., `recipes-core/images/johnblue-image.bb`):
```bitbake
IMAGE_INSTALL:append = " hello-world-module"
```

Then build the image:
```bash
bitbake johnblue-image
```

## Testing & Verification

### 1. Boot the System

```bash
cd /path/to/yocto-workspace/poky/build
runqemu qemux86-64 nographic
```

### 2. Verify Auto-Load Configuration

Check that the auto-load configuration file exists:
```bash
cat /etc/modules-load.d/hello_world.conf
```

**Expected output:**
```
hello_world
```

### 3. Verify Module is Auto-Loaded at Boot

Check if the module is already loaded:
```bash
lsmod | grep hello_world
```

**Expected output:**
```
hello_world            16384  0
```

Check kernel log for the init message:
```bash
dmesg | grep "Hello World"
```

**Expected output:**
```
[    X.XXXXXX] Hello World from kernel module!
```

### 4. Manual Module Operations

#### Unload the module (if auto-loaded):
```bash
rmmod hello_world
```

Check kernel log for goodbye message:
```bash
dmesg | tail
```

**Expected output:**
```
[    X.XXXXXX] Goodbye from kernel module!
```

#### Manually load the module:

**Option 1: Using modprobe (recommended)**
```bash
modprobe hello_world
```

**Option 2: Using insmod (direct path)**
```bash
insmod /lib/modules/$(uname -r)/updates/hello_world.ko
```

#### Verify module loaded successfully:
```bash
lsmod | grep hello_world
```

**Expected output:**
```
hello_world            16384  0
```

#### Check the hello message in kernel log:
```bash
dmesg | tail -n 20
```

**Expected output (last line):**
```
[    X.XXXXXX] Hello World from kernel module!
```

### 5. Module Information

View detailed module information:
```bash
modinfo hello_world
```

**Expected output:**
```
filename:       /lib/modules/6.6.111-yocto-standard/updates/hello_world.ko
version:        1.0
description:    Simple hello world kernel module
author:         Yocto
license:        MIT
...
```

### 6. Complete Test Sequence

```bash
# 1. Check if module is auto-loaded
lsmod | grep hello_world

# 2. View the hello message
dmesg | grep "Hello World"

# 3. Unload the module
rmmod hello_world

# 4. View the goodbye message
dmesg | tail -n 5

# 5. Reload the module
modprobe hello_world

# 6. View the hello message again
dmesg | tail -n 5

# 7. Final cleanup (unload)
rmmod hello_world
```

## Troubleshooting

### Module not found
```bash
# Check if the .ko file exists
ls /lib/modules/$(uname -r)/updates/

# Update module dependencies
depmod -a

# Try loading again
modprobe hello_world
```

### Auto-load not working
```bash
# Check if systemd-modules-load service is active
systemctl status systemd-modules-load.service

# Manually trigger module loading
systemctl restart systemd-modules-load.service

# Check service logs
journalctl -u systemd-modules-load.service
```

### Module already loaded error
```bash
# Unload first, then reload
rmmod hello_world
modprobe hello_world
```

## Recipe Details

### Key BitBake Variables

- `inherit module` - Inherits the kernel module build class
- `KERNEL_MODULE_AUTOLOAD += "hello_world"` - Auto-loads module at boot
- `STAGING_KERNEL_DIR` - Path to kernel source for building
- `INSTALL_MOD_PATH` - Installation destination for the module

### Module Source Code

The kernel module (`hello_world.c`) uses:
- `module_init()` - Entry point when module is loaded
- `module_exit()` - Exit point when module is unloaded
- `printk(KERN_INFO, ...)` - Kernel logging function

## License

MIT License

## References

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [Linux Kernel Module Programming Guide](https://sysprog21.github.io/lkmpg/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)
