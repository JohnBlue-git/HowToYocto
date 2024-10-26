# About this project
It is a practice about how to cook a minimal linux image attached with customized applications. Here, the build platform use Ubuntu 22.x on x86_64 machine.

## Make sure the build server meets the following requirements:
- 50 Gbytes of free disk space
- Git 1.8.3.1 or greater
- tar 1.28 or greater
- Python 3.6.0 or greater.
- gcc 7.5 or greater.
- GNU make 4.0 or greater

## Install sufficient packages or tools
```
sudo apt-get install gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint3 xterm python3-subunit mesa-common-dev zstd liblz4-tool
```

## Git clone poky (and remove git connection just for practice) 
### git clone
```
git clone git://git.yoctoproject.org/poky
```
### check out the kirkstone branch (Kirkstone release) and create new branch
```
cd poky
git checkout -t origin/kirkstone -b my-kirkstone
cd ..
```
### remove git (or submodule) connection
```
git rm --cached poky
git rm .gitmodules
rm -rf poky/.git
```
### upload poky (--force adds files ignored by .gitignore)
```
git add --force poky
git commit -m "..."
git push
```

## Initialize the project (each time)
```
cd poky
source oe-init-build-env

Common (bitbake) targets are:
    core-image-minimal
    core-image-full-cmdline
    core-image-sato
    core-image-weston
    meta-toolchain
    meta-ide-support
```
- `core-image-base`: A console-only image that fully supports the target.
- `core-image-minimal`: A small image allowing the device to just boot. It has recipe provides an image with the least number of packages to be a bootable image for a given platform (MACHINE) from a stock Yocto Project distribution. It is not necessarily the smallest image that can be created, as many size reductions can be made with kernel changes, etc. The default machine selected for Yocto build is named `qemux86-64`. This selection can be viewed in the file `conf/local.conf`.
- `core-image-sato`: An image with Sato support, a mobile environment and visual style that works with mobile devices.
- `core-image-clutter`: An image with support for the OpenGL-based toolkit Clutter
- `core-image-full-cmdline`: A console-only image with more full-featured system functionality installed.

## Creating a new layer
### create a new layer named meta-*
```
bitbake-layers create-layer meta-application
```
### bitBake would create additional recipe-example, we can remove it or change its name
```
tree

meta-application/
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
└── recipes-example
    └── example
        └── example.bb
```
### add new layer (to build/conf/bblayer.conf)
```
bitbake-layers add-layer meta-application

# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "${TOPDIR}"
BBFILES ?= ""

BBLAYERS ?= " \
  /media/disk4T/yujen/poky/meta \
  /media/disk4T/yujen/poky/meta-poky \
  /media/disk4T/yujen/poky/meta-yocto-bsp \
  /media/disk4T/yujen/poky/meta-application \
  "
```
### show layers
```
bitbake-layers show-layers

layer                 path                                      priority
==========================================================================
meta                  /media/disk4T/yujen/poky/meta             5
meta-poky             /media/disk4T/yujen/poky/meta-poky        5
meta-yocto-bsp        /media/disk4T/yujen/poky/meta-yocto-bsp   5
meta-application      /media/disk4T/yujen/poky/meta-application  6
```
### configure meta-*/conf/layer.conf file
```
# We have a conf and classes directory, add to BBPATH
BBPATH .= ":${LAYERDIR}"
LAYERSERIES_COMPAT_meta-application = "sumo"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
            ${LAYERDIR}/recipes-*/*/*.bbappend"

BBFILE_COLLECTIONS += "meta-application"
BBFILE_PATTERN_application = "^${LAYERDIR}/"
BBFILE_PRIORITY_application = "6"

# The following seem to be unnecessary
IMAGE_INSTALL += "_make _cmake "
```

## Add Recipes
### we have receipes-hello folder, which contains receipe hello, hellomake, hellocmake, hellomeson ...
```console
tree meta-application

meta-application/
├── conf
│   └── layer.conf
├── COPYING.MIT
├── README
├── recipes-application
│   └── images
│       ├── application-core-image-minimal.bb
│       └── core-image-minimal.bbappend
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
    └── hellotarball
        ├── files -> ../files
        └── hellotarball.bb
```

## Bitbake
### bitbake <target>
```
bitbake core-image-minimal
```
### bitbake <receipe>
```
bitbake hello

bitbake hellomake

bitbake hellocmake

bitbake hellomeson

bitbake hellotarball

bitbake hellofetch
```

## Clarification of {poky}/build/tmp directory:
- **abi_version**
- **buildstats** It is a detailed list of each recipe what "do_" actions has been executed with. including execution time, status, etc.
- **cache** These are the components has been built and available for reuse.
- **deploy** This is the place holder for the produced images as well as packages as well as the license information.
    * **images**
        * qemux86-64
        * …
    * **licenses**
    * **rpm**
        * qemux86_64
        * core2_64 
        * noarch
- **hosttools** This the storage of the host tools the build system depends on.
- **log** This is the place holder for the cooker build logs.
- **qa.log**
- **pkgdata** This place holds the lists of each package (RPM or DEB or IPKG, etc) content.
- **saved_tmpdir**
- **sstate-control** It is a list of the files produced by each particular recipe "do_" action.
- **stamps** A hash-stamp of each recipe each "do_" action.
- **sysroots-components** It is the list of each recipe artifacts to be placed to the target rootfs or to the build rootfs in case of "native" (i.e. executed on the build host computer) recipes.
- **sysroots-uninative** This is the toolchain shared libraries portion of the build rootfs.
- **work-shared**
- **work** It contains a set of recipe build result artifacts including recipe dependencies.
    * **all-poky-linux** holds the recipes that are architecture-independent, like scripts.
    * **x86_64-linux** used to hold recipes that are built for the build host that are used to build other recipes for the target machine. For more info check this [link](https://wiki.yoctoproject.org/wiki/Technical_FAQ#What_does_.22native.22_mean.3F)
    * **qemux86_64-poky-linux** holds recipes that are **machine-specific** like `core-image-minimal` as it is an image containing packages/boot/kernel binaries/configuration specific only to `qemux86_64`.
        * <{machine | qemux86_64}-poky-linux>/core-image-minimal/1.0-r0/rootfs/bin/
        * …
    * **core2-64-poky-linux** holds recipes that are **architecture-specific**, recipes that runs only on that architecture. It runs on `qemux86_64` machine and can run on other machines that are compatible with that architecture.
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/< app >
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/include
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/source
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/image
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/image/usr/include
        * <architecture | core2-64-poky-linux>/< app >/<version | 1.0-r0>/image/usr/bin

## Run image qemux86_64
```console
# "runqemu" contains in yocto porject. Running runqemu starts the VM and executes it, but it does not install or modify software on your host OS.
# "nographic" option runs QEMU in a mode that doesn’t use graphical output.
# run
sudo runqemu qemux86-64 nographic

# shutdown
shutdown -h now
```

## How to install application to image

Three normal approches to do it:

### Via local.conf
build/conf/local.conf
```console
IMAGE_INSTALL:append = " hellocmake"
# If only want to aplly to specific image
# IMAGE_INSTALL:append:pn-core-image-minimal = " hellocmake"

# Must use _append instead of the += operator (recommended on some resources available online) if you want to avoid ordering issues. As shown in its simplest use, IMAGE_INSTALL_append affects all images.
```
then build the image ...
```console
bibake core-image-minimal
```

### Via bb (to create new customized image)
meta-application/recipes-application/images/application-core-image-minimal.bb
```console
require recipes-core/images/application.bb
IMAGE_INSTALL += "hellocmake ..."
```
then build the image ...
```console
bibake application-core-image-minimal
```

### Via bbappend
meta-application/recipes-application/images/core-image-minimal.bbappend
```console
IMAGE_INSTALL += "hellocmake"
```
then build the image ...
```console
bibake core-image-minimal
```

## reference
https://kickstartembedded.com/2022/02/28/yocto-part-9-customising-images-by-adding-your-recipes/
https://docs.yoctoproject.org/dev/dev-manual/customizing-images.html

Advance with classes:
1. **Inheritance**:
    - To use a **`.bbclass`** file, a recipe simply needs to inherit the class. In most cases, inheriting the class is enough to enable its features.
    - Recipes can inherit multiple classes, allowing them to combine functionalities from different **`.bbclass`** files.
2. **Class Locations**:
    - **`.bbclass`** files are identified by their extension and are usually placed in specific subdirectories beneath the **`meta*/`** directory in the source directory:
        - **`classes-recipe/`**: Classes intended to be inherited by recipes individually.
        - **`classes-global/`**: Classes intended to be inherited globally.
        - **`classes/`**: Classes whose usage context is not clearly defined.
For instance, **cmake.bbclass** have already defined process for a noremal cmake build. When receipe's .bb file need to handle normal cmake build, we can use **inherit cmake** to use it.
For instance, **.bbclass** can also add **IMAGE_INSTALL:append** with the components that we want to install, and it can it inherited and shared accross all the receipes within the same directory.

## To be continue ...

### install qt
https://github.com/joaocfernandes/Learn-Yocto/blob/master/develop/Recipe-qt5.md

### how to build image for Raspberry Pi
https://kickstartembedded.com/2021/12/22/yocto-part-4-building-a-basic-image-for-raspberry-pi/

### about receipes and version and checksum
https://kickstartembedded.com/2022/01/21/yocto-part-6-understanding-and-creating-your-first-custom-recipe/ 
