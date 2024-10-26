SUMMARY = "Simple Hello World application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# way 1
#SRC_URI = "file://CMakeLists.txt \
#           file://include/echo.h \
#           file://source/echo.cpp \
#           file://source/hello.cpp \
#          "

# way 2
SRC_URI = "file://CMakeLists.txt \
           file://include/ \
           file://source/ \
          "

S = "${WORKDIR}"

inherit cmake

EXTRA_OECMAKE = ""
