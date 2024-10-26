SUMMARY = "Simple Hello World application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://tarball.tar.gz "

S = "${WORKDIR}"

inherit cmake

EXTRA_OECMAKE = ""
