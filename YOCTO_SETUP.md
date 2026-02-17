# Yocto Build Environment Setup Guide

## 📋 Prerequisites Check

Before starting, ensure you have:
- ✓ **~50 GB** free disk space (we currently have 21GB - may need to clean up)
- ✓ **Git** - `git --version`
- ✓ **Python 3** - `python3 --version` (3.6+)
- ✓ **gcc** - `gcc --version`
- ✓ **make** - `make --version`

## 🚀 Step 1: Install Missing Yocto Dependencies

```bash
# Update package lists
sudo apt-get update

# Install all required packages
sudo apt-get install -y \
  gawk wget git diffstat unzip texinfo gcc build-essential \
  chrpath socat cpio python3 python3-pip python3-pexpect xz-utils \
  debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa \
  libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd \
  liblz4-tool

# Verify installation
echo "Build tools check:"
which gawk wget git python3 gcc make chrpath socat cpio
```

## 🔧 Step 2: Install Google Repo Tool

```bash
# Create bin directory if it doesn't exist
mkdir -p ~/bin

# Download repo tool
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo

# Make it executable
chmod a+x ~/bin/repo

# Add to PATH (add this to ~/.bashrc or ~/.bash_profile)
export PATH="$HOME/bin:$PATH"

# Verify installation
repo --version
```

## 📁 Step 3: Initialize Yocto Workspace

```bash
# Create workspace directory (change path as needed)
mkdir -p ~/yocto-workspace
cd ~/yocto-workspace

# Initialize repo with this project's manifest
repo init -u https://github.com/JohnBlue-git/HowToYocto.git -b main

# Sync all repositories (this downloads Poky and meta-application)
# This may take 10-30 minutes depending on internet speed
repo sync

# Expected output shows these repos:
# - poky/
# - meta-application/
```

**⏱️ Estimated time: 15-30 minutes**

## 🏗️ Step 4: Source Yocto Build Environment

```bash
# Navigate to workspace
cd ~/yocto-workspace

# Source the Yocto environment
cd poky
source oe-init-build-env build

# You should now be in: ~/yocto-workspace/poky/build/
# And the prompt should change to indicate BitBake environment is active
```

## ✅ Step 5: Verify Setup - Check Recipe

```bash
# While in the build directory, verify the kernel module recipe
bitbake -p hello-world-module

# View recipe details
bitbake -e hello-world-module | head -20

# Check if recipe is found
bitbake-layers show-recipes | grep hello-world

# View layer configuration
bitbake-layers show-layers
```

## 🔨 Step 6: Build the Kernel Module Recipe

```bash
# Build just the kernel module
bitbake hello-world-module

# This will:
# 1. Download kernel source
# 2. Compile the module
# 3. Create kernel object (.ko) file
# 4. Install it to the sysroot

# Expected output location:
# build/tmp/deploy/images/qemux86-64/modules-*.tgz
```

**⏱️ Estimated time: 5-15 minutes (first run; subsequent builds are faster)**

## 🖥️ Step 7: Add to Image and Build Full Image

```bash
# Edit build configuration
nano build/conf/local.conf

# Find the line with IMAGE_INSTALL and add:
# IMAGE_INSTALL += "hello-world-module"

# Or if it doesn't exist, add at the end:
# IMAGE_INSTALL = "hello-world-module"

# Build the minimal image with the kernel module
bitbake core-image-minimal

# This will build:
# - Bootable Linux image
# - Including hello-world-module
```

**⏱️ Estimated time: 20-40 minutes (first run is slower)**

## 🧪 Step 8: Test the Kernel Module

```bash
# Boot the QEMU virtual machine
sudo runqemu qemux86-64 nographic

# Inside the QEMU shell, load the module:
insmod /lib/modules/$(uname -r)/kernel/hello_world.ko

# Check kernel output (should show "Hello World from kernel module!")
dmesg | tail -5

# Unload the module:
rmmod hello_world

# Verify unload message
dmesg | tail -2

# Exit QEMU
shutdown -h now
```

## 📊 Build Directory Structure

After building, check outputs:

```bash
# View downloaded sources
ls -la build/tmp/work/*/hello-world-module/

# View built modules
find build/tmp/deploy -name "*.ko" -type f

# View image outputs
ls -la build/tmp/deploy/images/qemux86-64/

# Check build logs
build/tmp/work/*/hello-world-module/*/log.do_*
```

## 🐛 Troubleshooting

### Issue: "repo: command not found"
**Solution:** Ensure `~/bin` is in your PATH:
```bash
export PATH="$HOME/bin:$PATH"
# Add to ~/.bashrc to make permanent
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Issue: "Not enough space"
**Solution:** Yocto needs 50GB. Check available space:
```bash
df -h
# If low on space, clean build artifacts:
bitbake -c cleanall hello-world-module
# Or deep clean (removes everything):
rm -rf build/tmp/
```

### Issue: "Recipe not found"
**Solution:** Verify layers are configured:
```bash
bitbake-layers show-layers
# meta-application should appear with priority 6
```

### Issue: Build fails with kernel version mismatch
**Solution:** Update kernel source cache:
```bash
bitbake -c fetchall hello-world-module
bitbake -c cleanall hello-world-module
bitbake hello-world-module
```

## 📝 Quick Reference Commands

```bash
# Parse recipes
bitbake -p hello-world-module

# Show available recipes
bitbake-layers show-recipes

# Show layers
bitbake-layers show-layers

# Get recipe variables
bitbake -e hello-world-module | grep VARIABLE_NAME

# Build specific recipe
bitbake hello-world-module

# Build image
bitbake core-image-minimal

# Clean recipe
bitbake -c clean hello-world-module

# Force rebuild
bitbake -f hello-world-module

# View build logs
tail -f build/tmp/work/*/hello-world-module/*/temp/log.do_compile
```

## 📚 More Information

- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [BitBake User Manual](https://docs.yoctoproject.org/bitbake/)
- [Creating Recipes](https://docs.yoctoproject.org/3.4/dev-manual/dev-manual-common.html#creating-a-recipe)
- [Kernel Modules in Yocto](https://www.kernel.org/doc/html/latest/kbuild/modules.html)

---

**Next Steps:**
1. Follow steps 1-4 to set up your environment
2. Once in the build directory, come back and run step 5 to verify
3. Proceed with building!
