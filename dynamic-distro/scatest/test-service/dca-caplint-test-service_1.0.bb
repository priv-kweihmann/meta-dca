## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann
SUMMARY = "DCA caplint test service"
DESCRIPTION = "Test service with too many capabilities set"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837"

SRC_URI = "\
           file://dca-caplint-test-service.service \
          "

inherit systemd

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dca-caplint-test-service.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} += "dca-caplint-test-service.service"

FILES_${PN} += "${systemd_system_unitdir}"
