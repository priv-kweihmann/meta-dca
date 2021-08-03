## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann
SUMMARY = "DCA filelife service"
DESCRIPTION = "service files for DCA filelife integration"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837"

DEPENDS += "${BPN}-native"

SRC_URI = "\
           file://dca-filelife.service \
          "

inherit systemd

do_install:append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dca-filelife.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE:${PN} += "dca-filelife.service"

FILES:${PN} += "${systemd_system_unitdir}"

RDEPENDS:${PN} += "\
                   bcc \
                   dca-unlinksnoop \
                   "
