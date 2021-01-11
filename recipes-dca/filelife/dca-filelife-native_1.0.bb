## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann
SUMMARY = "DCA filelife test service sca-description"
DESCRIPTION = "sca-description for dca-filelife"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837"

SRC_URI = "\
           file://filelife.sca.description \
          "

inherit native
inherit systemd

do_install_append() {
    install -d ${D}${datadir}
    install -m 0644 ${WORKDIR}/filelife.sca.description ${D}${datadir}
}

FILES_${PN} += "${datadir}"
