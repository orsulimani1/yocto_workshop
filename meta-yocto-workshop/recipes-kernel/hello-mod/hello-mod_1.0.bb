DESCRIPTION = "Hello World Kernel Module"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://hello.c \
           file://Makefile"

S = "${WORKDIR}"

# Inherit the module class which sets up the environment for kernel modules
inherit module

MODULE_NAME = "hello"

# If you want the module to load automatically on boot, specify here:
KERNEL_MODULE_AUTOLOAD += " hello"

