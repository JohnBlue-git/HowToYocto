SUMMARY = "Hello World Kernel Module"
DESCRIPTION = "A simple kernel module that prints 'hello world' to the kernel log"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit module

SRC_URI = "file://hello_world.c \
           file://Makefile \
          "

S = "${WORKDIR}"

EXTRA_OEMAKE = "KERNEL_SRC=${STAGING_KERNEL_DIR}"

do_compile() {
    unset CFLAGS CPPFLAGS CXXFLAGS LDFLAGS
    oe_runmake -C ${STAGING_KERNEL_DIR} M=${S} modules
}

do_install() {
    oe_runmake -C ${STAGING_KERNEL_DIR} M=${S} modules_install INSTALL_MOD_PATH=${D}
}
