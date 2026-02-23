SUMMARY = "Simple Hello World application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://tarball.tar.gz "

S = "${WORKDIR}"

inherit cmake

# Override the executable name to hellotarball
EXTRA_OECMAKE = ""

do_configure:prepend() {
    # Modify CMakeLists.txt to change the executable name from hellocmake to hellotarball
    sed -i 's/add_executable(hellocmake/add_executable(hellotarball/g' ${S}/CMakeLists.txt
    sed -i 's/install(TARGETS hellocmake/install(TARGETS hellotarball/g' ${S}/CMakeLists.txt
    sed -i 's/project(hellocmake)/project(hellotarball)/g' ${S}/CMakeLists.txt
}
