# About this project

It is a practice about how to cook a minimal linux image attached with customized applications. Here, the build platform uses Ubuntu 22.x on x86_64 machine.

This project uses the **Google Repo tool** to manage the Yocto Poky project and the custom meta-application layer. The repository manifest separates the upstream Poky project from your custom metadata layer.

## Project Structure

- **meta-application/**: Custom metadata layer with recipes and image configurations
- **.repo/manifests/**: Repository manifest files for managing the project workspace
- **poky/**: Yocto Poky project (cloned via repo manifest, not stored in this repo)

## Prerequisites

### System Requirements

- 50 Gbytes of free disk space
- Git 1.8.3.1 or greater
- tar 1.28 or greater
- Python 3.6.0 or greater
- gcc 7.5 or greater
- GNU make 4.0 or greater
- Repo tool (Google's multi-repository tool)

### Install System Packages

```bash
sudo apt-get install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool
```

### Install Repo Tool

```bash
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
# Make sure ~/bin is in your PATH
```

## Setup Project with Repo

### Initialize Repo Workspace

Create a new directory for the workspace and initialize it:

```bash
mkdir -p ~/yocto-workspace
cd ~/yocto-workspace

# Initialize repo with this project's manifest
repo init -u https://github.com/JohnBlue-git/HowToYocto.git -b main

# Download all projects
repo sync
```

### Project Initialization (Each Time)

```bash
# Navigate to the workspace (after repo init and repo sync)
cd ~/yocto-workspace

# Source the Yocto environment from Poky
cd poky
source oe-init-build-env build

# Now you're in the build directory - ready to build!
```

## Building Images

Common bitbake targets:

- `core-image-minimal`: Small bootable image with minimal packages
- `core-image-base`: Console-only image with full target support
- `core-image-full-cmdline`: Console-only with more system functionality
- `core-image-sato`: Image with Sato mobile environment
- `core-image-clutter`: Image with OpenGL Clutter toolkit support
- `meta-toolchain`: Toolchain for remote development
- `meta-ide-support`: IDE support files

### Build a Target Image

```bash
bitbake core-image-minimal
```

### Build a Recipe

```bash
bitbake hello
bitbake hellomake
bitbake hellocmake
bitbake hellomeson
bitbake hellotarball
bitbake hellofetch
bitbake hellorust
```

## Installing Applications to Images

### Method 1: Via local.conf

Edit `build/conf/local.conf`:

```conf
IMAGE_INSTALL:append = " hellocmake"
# Or for specific images:
# IMAGE_INSTALL:append:pn-core-image-minimal = " hellocmake"
```

Then build:

```bash
bitbake core-image-minimal
```

### Method 2: Create Custom Image Recipe

Create `meta-application/recipes-application/images/application-core-image-minimal.bb`:

```bb
require recipes-core/images/core-image-minimal.bb
IMAGE_INSTALL += "hellocmake"
```

Then build:

```bash
bitbake application-core-image-minimal
```

### Method 3: Via bbappend

Create `meta-application/recipes-application/images/core-image-minimal.bbappend`:

```bb
IMAGE_INSTALL += "hellocmake"
```

Then build:

```bash
bitbake core-image-minimal
```

## Creating and Managing Layers

### View Available Layers

```bash
cd poky
source oe-init-build-env build
bitbake-layers show-layers
```

Expected output:

```
layer                 path                                      priority
==========================================================================
meta                  ../../poky/meta                           5
meta-poky             ../../poky/meta-poky                      5
meta-yocto-bsp        ../../poky/meta-yocto-bsp                 5
meta-application      ../../meta-application                    6
```

### Create a New Layer

To create an additional custom layer:

```bash
cd poky
bitbake-layers create-layer ../meta-mynewlayer
bitbake-layers add-layer ../meta-mynewlayer
```

### Configure layer.conf

Edit the new layer's `conf/layer.conf`:

```conf
# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "mynewlayer"
BBFILE_PATTERN_mynewlayer = "^${LAYERDIR}/"
BBFILE_PRIORITY_mynewlayer = "6"
```

## meta-application Layer Structure

The `meta-application` layer includes example recipes:

```
meta-application/
├── conf
│   └── layer.conf
├── COPYING.MIT
└── recipes-hello
    ├── files
    │   ├── CMakeLists.txt
    │   ├── include
    │   │   └── echo.h
    │   ├── Makefile
    │   ├── meson.build
    │   ├── source
    │   │   ├── echo.cpp
    │   │   └── hello.cpp
    │   └── tarball.tar.gz
    ├── hello
    │   ├── files -> ../files
    │   └── hello.bb
    ├── hellocmake
    │   ├── files -> ../files
    │   └── hellocmake.bb
    ├── hellofetch
    │   └── hellofetch.bb
    ├── hellomake
    │   ├── files -> ../files
    │   └── hellomake.bb
    ├── hellomeson
    │   ├── files -> ../files
    │   └── hellomeson.bb
    ├── hellotarball
    │   ├── files -> ../files
    │   └── hellotarball.bb
    └── hellorust
        ├── files
        │   └── hellorust/
        │       ├── Cargo.toml
        │       ├── Cargo.lock
        │       └── src/
        │           └── main.rs
        ├── hellorust.bb
        └── README.md
```

## Understanding Yocto Build Directory Structure

The `build/tmp/` directory contains build artifacts:

- **abi_version**: ABI version information
- **buildstats**: Detailed recipe build statistics with execution times
- **cache**: Built components available for reuse
- **deploy**: Output images, packages, and license information
  - **images/**: Generated image files per machine (qemux86-64, etc.)
  - **licenses/**: License files
  - **rpm/**: RPM packages organized by architecture
- **hosttools**: Host tools required by the build system
- **log**: Build system logs
- **qa.log**: Quality assurance logs
- **pkgdata**: Package content information
- **sstate-control**: SHA256 sstate tracking information
- **stamps**: Recipe task status hash stamps
- **sysroots-components**: Recipe artifacts to be installed
- **sysroots-uninative**: Cross-toolchain shared libraries
- **work-shared**: Shared build files
- **work**: Recipe build result artifacts
  - **all-poky-linux/**: Architecture-independent recipes
  - **x86_64-linux/**: Build host (native) recipes
  - **qemux86_64-poky-linux/**: Machine-specific recipes
  - **core2-64-poky-linux/**: Architecture-specific recipes

## Running QEMU Image

For qemux86-64 machine:

```bash
sudo runqemu qemux86-64 nographic

# To shutdown:
shutdown -h now
```

## Class Inheritance

Bitbake classes provide predefined functionality:

### Using Classes

Recipes inherit classes to use predefined build processes:

```bb
inherit cmake
inherit make
inherit autotools
```

### Class Locations

- **classes-recipe/**: Recipe-specific classes
- **classes-global/**: Global classes
- **classes/**: General-purpose classes

### Common Classes

- `cmake.bbclass`: CMake build system
- `autotools.bbclass`: Autotools build system
- `python.bbclass`: Python recipes

## References

- [Yocto Project Official Documentation](https://docs.yoctoproject.org/)
- [Customizing Images](https://docs.yoctoproject.org/dev/dev-manual/customizing-images.html)
- [Creating Recipes](https://kickstartembedded.com/2022/01/21/yocto-part-6-understanding-and-creating-your-first-custom-recipe/)
- [Raspberry Pi Support](https://kickstartembedded.com/2021/12/22/yocto-part-4-building-a-basic-image-for-raspberry-pi/)
- [Google Repo Documentation](https://gerrit.googlesource.com/git-repo/+/refs/heads/master/README.md)

## To be continued...

- Qt5 integration
- Advanced recipe development
- Custom image creation
- Performance optimization
