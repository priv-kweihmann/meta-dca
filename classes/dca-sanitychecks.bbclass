## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

addhandler dca_check_sanity_eventhandler
dca_check_sanity_eventhandler[eventmask] = "bb.event.SanityCheck"
python dca_check_sanity_eventhandler() {
    _qemumem = int((d.getVar("QB_MEM") or "0").replace("-m ", ""))
    distro_features = set(d.getVar("DISTRO_FEATURES").split())

    if _qemumem < 1024:
        bb.warn("'QB_MEM' shall be at least set to '-m 1024'")

    if d.getVar("QEMU_USE_KVM") != "1":
        bb.warn("Usage of 'QEMU_USE_KVM' is highly recommended")
    
    if "systemd" not in distro_features:
        bb.fatal("dca-caplint integration does require 'systemd' in DISTRO_FEATURES")
}
