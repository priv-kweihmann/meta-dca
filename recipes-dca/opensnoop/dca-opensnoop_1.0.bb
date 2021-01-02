## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann
SUMMARY = "DCA opensnoop service"
DESCRIPTION = "service files for DCA opensnoop integration"

LICENSE = "BSD-2-Clause & Apache-2.0"
LIC_FILES_CHKSUM = "\
                    file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837 \
                    file://${WORKDIR}/opensnoop-enh.bt;beginline=12;endline=14;md5=6db9f21fad52021cad2ddef2eafb1a34 \
                   "

DEPENDS += "${BPN}-native"

SRC_URI = "\
           file://dca-opensnoop.service \
           file://opensnoop-enh.bt \
          "

inherit systemd

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dca-opensnoop.service ${D}${systemd_system_unitdir}
    install -d ${D}${datadir}/dca/tools/
    install -m 0644 ${WORKDIR}/opensnoop-enh.bt ${D}${datadir}/dca/tools/
}

SYSTEMD_SERVICE_${PN} += "dca-opensnoop.service"

FILES_${PN} += "${systemd_system_unitdir} ${datadir}"

RDEPENDS_${PN} += "\
                   bpftrace \
                   dca-execsnoop \
                   "
