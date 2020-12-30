## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann
SUMMARY = "DCA execsnoop service"
DESCRIPTION = "Trace new processes via exec() syscalls"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837"

SRC_URI = "\
           file://dca-caplint-execsnoop.service \
          "

inherit systemd

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dca-caplint-execsnoop.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE_${PN} += "dca-caplint-execsnoop.service"

FILES_${PN} += "${systemd_system_unitdir}"

RDEPENDS_${PN} += "\
                   bpftrace \
                   "
