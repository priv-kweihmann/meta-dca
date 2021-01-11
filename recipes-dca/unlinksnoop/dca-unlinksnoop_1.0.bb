## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann
SUMMARY = "DCA unlinksnoop service"
DESCRIPTION = "Trace unlink syscalls with bpftrace"

LICENSE = "BSD-2-Clause & Apache-2.0"
LIC_FILES_CHKSUM = "\
                    file://${DCA_LAYERDIR}/LICENSE;md5=b154026c9aa139037c0a998e2c76c837 \
                    file://${WORKDIR}/unlinksnoop.bt;beginline=5;endline=8;md5=f44c8be705b8cb118b380256ff56efb7 \
                   "

SRC_URI = "\
           file://dca-unlinksnoop.service \
           file://unlinksnoop.bt \
          "

inherit systemd

do_install_append() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/dca-unlinksnoop.service ${D}${systemd_system_unitdir}
    install -d ${D}${datadir}/dca/tools
    install -m 0644 ${WORKDIR}/unlinksnoop.bt ${D}${datadir}/dca/tools/
}

SYSTEMD_SERVICE_${PN} += "dca-unlinksnoop.service"

FILES_${PN} += "${systemd_system_unitdir} ${datadir}"

RDEPENDS_${PN} += "\
                   bpftrace \
                   "
