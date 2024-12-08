DESCRIPTION = "Example recipe for hello yocto application"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "git://github.com/orsulimani1/yocto_workshop_example.git;protocol=https;branch=main"

SRCREV = "dc34458749d583c383ee147ac2237e65dff9934d"


S = "${WORKDIR}/git"

inherit cmake

EXTRA_OECMAKE = "-DENABLE_FEATURE=ON"

do_install() {
    # Create the target directory in the image
    install -d ${D}${bindir}
    
    # Copy the binary to the target directory
    install -m 0755 ${B}/hello_yocto_from_git/hello_yocto_from_git ${D}${bindir}/hello_yocto_from_git
}


FILES_${PN} = "${bindir}/hello_git"