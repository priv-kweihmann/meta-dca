## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

inherit testimage
inherit sca-datamodel
inherit sca-helper
inherit sca-license-filter
inherit sca-suppress

inherit dca-image-backtrack
inherit dca-deploy

inherit dca-module-execsnoop
inherit dca-module-systemddump

SCA_RAW_RESULT_FILE[caplint] = "json"

TEST_SUITES_append = " zzz_dca_caplint"
IMAGE_INSTALL_append = " \
                        dca-caplint \
                        kernel-dev \
                        kernel-module-kheaders \
                       "

def dsa_caplint_cap_map(d, _map):
    import re
    pattern = r"^\d+:\d+:\d+\s+(?P<uid>\d+)\s+(?P<pid>\d+)\s+\d+\s+(?P<app>.*?)\s+\d+\s+(?P<cap>[A-Z_]*)\s+\d+\s+\d+"
    with open(os.path.join(d.getVar('T'), "dca-caplint-capable.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            for k,v in _map.items():
                if m.group("pid") == v["MainPID"] or \
                    m.group("pid") in v["Children"]:
                    v["Caps"] = list(set(v["Caps"] + [m.group("cap")]))

def do_dca_conv_caplint(d, _map):
    import os
    import re

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []

    _suppress = sca_suppress_init(d, "SCA_CAPLINT_EXTRA_SUPPRESS", None)
    _findings = []

    for k, v in _map.items():
        try:
            _caps = sorted(set([x for x in v["CapabilityBoundingSet"] if x not in v["Caps"]]))
            if not _caps:
                continue
            for c in _caps:
                g = sca_get_model_class(d,
                                        PackageName=package_name,
                                        Tool="caplint",
                                        BuildPath=buildpath,
                                        File=v["FragmentPath"],
                                        Message="'{}' set as capability but it is not used".format(c),
                                        ID="caplint.caplint.capabilities.{}".format(c),
                                        Severity="warning")
                if _suppress.Suppressed(g):
                    continue
                _findings += dca_backtrack_findings(d, g)
        except Exception as e:
            sca_log_note(d, str(e))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_dca_caplint() {
    import json

    # Get systemd dump map
    _map = dca_module_systemddump(d, 
                                  { 
                                    "CapabilityBoundingSet": [],
                                    "Caps": [], 
                                    "Children": [], 
                                    "FragmentPath": "/does/not/exist", 
                                    "MainPID": "-1", 
                                  },
                                  ["MainPID", "FragmentPath", "CapabilityBoundingSet"])
    # Get children process PIDs from execsnoop
    for k, v in _map.items():
        v["Children"] = dca_module_execsnoop(d, v["MainPID"])
    # Map against seen capabilities
    dsa_caplint_cap_map(d, _map)

    with open(sca_raw_result_file(d, "caplint"), "w") as o:
        json.dump(_map, o)

    d.setVar("SCA_DATAMODEL_STORAGE", "{}/caplint.dm".format(d.getVar("T")))
    dm_output = do_dca_conv_caplint(d, _map)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    dca_deploy(d, "CAPLINT", "caplint")
}

do_testimage[postfuncs] += "do_dca_caplint"
