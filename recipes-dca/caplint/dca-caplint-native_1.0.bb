## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann
SUMMARY = "DCA caplint test service sca-description"
DESCRIPTION = "sca-description for dca-caplint"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837"

SRC_URI = "\
           file://caplint.sca.description \
          "

inherit native
inherit systemd

do_install:append() {
    install -d ${D}${datadir}
    install -m 0644 ${WORKDIR}/caplint.sca.description ${D}${datadir}
}

FILES:${PN} += "${datadir}"
