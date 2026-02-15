SUMMARY = "Simple Hello World application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# To avoid the checksum checking error
BB_STRICT_CHECKSUM = "0"
# SRU_URI
UBRANCH = "master"
SRC_URI = "git://github.com/ttroy50/cmake-examples.git;branch=${UBRANCH}"
SRCREV = "2b27fc75c40447c8cf9b371cc21224dd96d6ce45"
#SRCPV = ""

S = "${WORKDIR}/git"

# Specific fetch
#do_fetch() {
# Clone the repository
#  git clone ${SRC_URI} ${S}
#  git clone -b master https://github.com/ttroy50/cmake-examples.git ${WORKDIR}/git 
# Navigate to the cloned repository
#  cd ${S}
# Checkout to the specific branch/tag/commit
#  git checkout ${SRCREV}
# Move the desired directory to ${WORKDIR}/desired_directory
#  mkdir -p ${S}
#  cp -r ${DL_DIR}/cmake-examples/01-basic/A-hello-cmake ${S}	
#  cp ${S}/01-basic/A-hello-cmake/* ${S}/
#}

inherit cmake

do_configure() {
  cmake -S ${S}/01-basic/A-hello-cmake/
}

do_compile() {
  ${MAKE}
}

do_install() {
  install -d ${D}${bindir}
  install -m 0755 hello_cmake ${D}${bindir}
}

EXTRA_OECMAKE = ""
