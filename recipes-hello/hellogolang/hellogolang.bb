SUMMARY = "Simple Hello World program in Go"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit go

GO_IMPORT = "example.com/hellogolang"
SRC_URI = "file://src/${GO_IMPORT}/main.go"
S = "${WORKDIR}/src/${GO_IMPORT}"

do_compile() {
    export GO111MODULE=off
    cd ${S}
    ${GO} build -v -o ${B}/hellogolang .
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/hellogolang ${D}${bindir}/hellogolang
}
