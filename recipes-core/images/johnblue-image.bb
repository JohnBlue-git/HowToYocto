DESCRIPTION = "Custom image based on core-image-minimal"
LICENSE = "MIT"

# - Place inherit early in the .bb file, typically after metadata definitions (DESCRIPTION, LICENSE, etc.).
# - If you need to override class-defined variables, place after inherit (do_compile, do_install, etc, ...).
inherit core-image

# Install all recipes from this project
IMAGE_INSTALL:append = " \
    hello \
    hellocmake \
    hellofetch \
    hellomake \
    hellomeson \
    hellotarball \
    hellorust \
    hellogolang \
    hello-world-module \
    simulated-led-module \
"

# Optional: Set root password (empty for no password)
# EXTRA_USERS_PARAMS = "usermod -P root root;"

# Optional: Add extra disk space (in KB)
IMAGE_ROOTFS_EXTRA_SPACE = "1048576"
