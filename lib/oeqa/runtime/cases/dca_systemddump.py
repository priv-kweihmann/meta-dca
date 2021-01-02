## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

import os
import json

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCASystemdDump(OERuntimeTestCase):

    IGNORED_UNITS = [
                    "-.mount",
                    "autovt@.service",
                    "bad.service",
                    "basic.target",
                    "blockdev@.target",
                    "bluetooth.target",
                    "boot-complete.target",
                    "console-getty.service",
                    "container-getty@.service",
                    "ctrl-alt-del.target",
                    "dbus-org.freedesktop.hostname1.service",
                    "dbus-org.freedesktop.locale1.service",
                    "dbus-org.freedesktop.login1.service",
                    "dbus-org.freedesktop.network1.service",
                    "dbus-org.freedesktop.resolve1.service",
                    "dbus-org.freedesktop.timedate1.service",
                    "dbus-org.freedesktop.timesync1.service",
                    "dbus.service",
                    "dbus.socket",
                    "dca-caplint-capable.service ",
                    "dca-execsnoop.service ",
                    "dca-opensnoop.service",
                    "debug-shell.service",
                    "default.target",
                    "dev-hugepages.mount",
                    "dev-mqueue.mount",
                    "emergency.service",
                    "emergency.target",
                    "exit.target",
                    "final.target",
                    "first-boot-complete.target",
                    "getty-pre.target",
                    "getty.target",
                    "getty@.service",
                    "graphical.target",
                    "halt.target",
                    "hibernate.target",
                    "hybrid-sleep.target",
                    "initrd-cleanup.service",
                    "initrd-fs.target",
                    "initrd-parse-etc.service",
                    "initrd-root-device.target",
                    "initrd-root-fs.target",
                    "initrd-switch-root.service",
                    "initrd-switch-root.target",
                    "initrd-udevadm-cleanup-db.service",
                    "initrd.target",
                    "kexec.target",
                    "kmod-static-nodes.service",
                    "ldconfig.service",
                    "local-fs-pre.target",
                    "local-fs.target",
                    "modprobe@.service",
                    "multi-user.target",
                    "network-online.target",
                    "network-pre.target",
                    "network.target",
                    "nss-lookup.target",
                    "nss-user-lookup.target",
                    "paths.target",
                    "poweroff.target",
                    "printer.target",
                    "quotaon.service",
                    "rc-local.service",
                    "reboot.target",
                    "remote-fs-pre.target",
                    "remote-fs.target",
                    "rescue.service",
                    "rescue.target",
                    "rngd.service",
                    "rpcbind.target",
                    "run-postinsts.service",
                    "runlevel0.target",
                    "runlevel1.target",
                    "runlevel2.target",
                    "runlevel3.target",
                    "runlevel4.target",
                    "runlevel5.target",
                    "runlevel6.target",
                    "serial-getty@.service",
                    "shutdown.target",
                    "sigpwr.target",
                    "sleep.target",
                    "slices.target",
                    "smartcard.target",
                    "sockets.target",
                    "sound.target",
                    "suspend-then-hibernate.target",
                    "suspend.target",
                    "swap.target",
                    "sys-fs-fuse-connections.mount",
                    "sys-kernel-config.mount",
                    "sys-kernel-debug.mount",
                    "sys-kernel-tracing.mount",
                    "sysinit.target",
                    "syslog.service",
                    "syslog.socket",
                    "system-update-cleanup.service",
                    "system-update-pre.target",
                    "system-update.target",
                    "systemd-ask-password-console.path",
                    "systemd-ask-password-console.service",
                    "systemd-ask-password-wall.path",
                    "systemd-ask-password-wall.service",
                    "systemd-backlight@.service",
                    "systemd-boot-check-no-failures.service",
                    "systemd-exit.service",
                    "systemd-fsck-root.service",
                    "systemd-fsck@.service",
                    "systemd-halt.service",
                    "systemd-hibernate-resume@.service",
                    "systemd-hibernate.service",
                    "systemd-hostnamed.service",
                    "systemd-hwdb-update.service",
                    "systemd-hybrid-sleep.service",
                    "systemd-initctl.service",
                    "systemd-initctl.socket",
                    "systemd-journal-catalog-update.service",
                    "systemd-journal-flush.service",
                    "systemd-journald-audit.socket",
                    "systemd-journald-dev-log.socket",
                    "systemd-journald-varlink@.socket",
                    "systemd-journald.service",
                    "systemd-journald.socket",
                    "systemd-journald@.service",
                    "systemd-journald@.socket",
                    "systemd-kexec.service",
                    "systemd-localed.service",
                    "systemd-logind.service",
                    "systemd-machine-id-commit.service",
                    "systemd-modules-load.service",
                    "systemd-network-generator.service",
                    "systemd-networkd-wait-online.service",
                    "systemd-networkd.service",
                    "systemd-networkd.socket",
                    "systemd-poweroff.service",
                    "systemd-pstore.service",
                    "systemd-quotacheck.service",
                    "systemd-random-seed.service",
                    "systemd-reboot.service",
                    "systemd-remount-fs.service",
                    "systemd-resolved.service",
                    "systemd-suspend-then-hibernate.service",
                    "systemd-suspend.service",
                    "systemd-sysctl.service",
                    "systemd-sysusers.service",
                    "systemd-time-wait-sync.service",
                    "systemd-timedated.service",
                    "systemd-timesyncd.service",
                    "systemd-tmpfiles-clean.service",
                    "systemd-tmpfiles-clean.timer",
                    "systemd-tmpfiles-setup-dev.service",
                    "systemd-tmpfiles-setup.service",
                    "systemd-udev-settle.service",
                    "systemd-udev-trigger.service",
                    "systemd-udevd-control.socket",
                    "systemd-udevd-kernel.socket",
                    "systemd-udevd.service",
                    "systemd-update-done.service",
                    "systemd-update-utmp-runlevel.service",
                    "systemd-update-utmp.service",
                    "systemd-userdbd.service",
                    "systemd-userdbd.socket",
                    "systemd-vconsole-setup.service",
                    "systemd-volatile-root.service",
                    "time-set.target",
                    "time-sync.target",
                    "timers.target",
                    "tmp.mount",
                    "umount.target",
                    "usb-gadget.target",
                    "user-runtime-dir@.service",
                    "user.slice",
                    "user@.service",
                    "var-volatile-cache.service",
                    "var-volatile-lib.service",
                    "var-volatile-spool.service",
                    "var-volatile-srv.service",
                    "var-volatile.mount",
                    ]

    @OERequirePackage(['systemd'])
    def test_dca_systemddump(self):
        """Dumps information about all systemd units in json format
        """
        status, output = self.target.run("systemctl list-unit-files --no-pager --no-legend | cut -d' ' -f 1 | sort | tr '\n' ' '")
        _result = {}
        for unit in output.split(" "):
            if unit in DCASystemdDump.IGNORED_UNITS:
                continue
            status, output = self.target.run("systemctl show --all {}".format(unit))
            _result[unit] = {}
            for line in output.split("\n"):
                if "=" not in line:
                    continue
                _chunks = line.strip("\n").split("=")
                if len(_chunks) > 1:
                    _key = _chunks[0]
                    _value = _chunks[1]
                else:
                    _key = _chunks[0]
                    _value = ""
                _result[unit][_key] = _value
        with open(os.path.join(self.tc.td.get('T'), "dca-systemddump.json"), "w") as o:
            json.dump(_result, o)
