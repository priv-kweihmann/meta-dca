## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

inherit testimage
inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-helper
inherit sca-license-filter
inherit sca-suppress

inherit dca-image-backtrack
inherit dca-deploy

SCA_RAW_RESULT_FILE[caplint] = "json"

TEST_SUITES_append = " dca_caplint"
IMAGE_INSTALL_append = " \
                        dca-caplint \
                        kernel-dev \
                        kernel-module-kheaders \
                       "

def dsa_caplint_services_map(d):
    import json

    _map = {}
    ## Rework to use the JSON input
    with open(os.path.join(d.getVar('T'), "dca-systemddump.json")) as i:
        for k,v in json.load(i).items():
            _map[k] = { "Caps": [], 
                        "Children": []
                      }
            if "CapabilityBoundingSet" in v:
                _map[k]["CapabilityBoundingSet"] = list(set([x.upper() for x in v["CapabilityBoundingSet"].split(" ")]))
            else:
                _map[k]["CapabilityBoundingSet"] = []
            if "MainPID" in v:
                _map[k]["MainPID"] = v["MainPID"]
            else:
                _map[k]["MainPID"] = "-1"
            if "FragmentPath" in v:
                _map[k]["FragmentPath"] = v["FragmentPath"]
            else:
                _map[k]["FragmentPath"] = "/does/not/exist"
    return _map

def dsa_caplint_pid_map(d, _map):
    import re
    pattern = r"^(\w+)\s+(?P<pid>\d+)\s+(?P<ppid>\d+)\s+\d+\s+.*"

    _initial_map = {}
    # Initial loop
    with open(os.path.join(d.getVar('T'), "dca-caplint-execsnoop.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            if not m.group("ppid") in _map:
                _initial_map[m.group("ppid")] = []
            _initial_map[m.group("ppid")].append(m.group("pid"))

    def _maploop(_id, _m):
        res = []
        if _id in _m:
            res += _m[_id]
            for v in _m[_id]:
                res += _maploop(v, _m)
        return res

    _resmap = {k:_maploop(k, _initial_map) for k,_ in _initial_map.items()}
    for k, v in _map.items():
        if v["MainPID"] in _resmap.keys():
            v["Children"] = _resmap[v["MainPID"]]

def dsa_caplint_cap_map(d, _map):
    import re
    pattern = r"^\d+:\d+:\d+\s+(?P<uid>\d+)\s+(?P<pid>\d+)\s+\d+\s+(?P<app>.*?)\s+\d+\s+(?P<cap>[A-Z_]*)\s+\d+\s+\d+"
    with open(os.path.join(d.getVar('T'), "dca-caplint-capable.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            for k,v in _map.items():
                if m.group("pid") == v["MainPID"] or \
                    m.group("pid") in v["Children"]:
                    if "Caps" not in v:
                        v["Caps"] = []
                    v["Caps"].append(m.group("cap"))

def do_dca_conv_caplint(d, _map):
    import os
    import re

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")

    items = []

    _suppress = sca_suppress_init(d, "SCA_CAPLINT_EXTRA_SUPPRESS", None)
    _findings = []

    for k, v in _map.items():
        if sorted(set(v["CapabilityBoundingSet"])) != sorted(set(v["Caps"])):
            try:
                _caps = sorted(set([x for x in v["CapabilityBoundingSet"] if x not in v["Caps"]]))
                if not _caps:
                    continue
                _msg = "{add} set as capabilities are not used".format(add=_caps)
                g = sca_get_model_class(d,
                                        PackageName=package_name,
                                        Tool="caplint",
                                        BuildPath=buildpath,
                                        File=v["FragmentPath"],
                                        Message=_msg,
                                        ID="caplint.caplint.capabilities",
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

    _map = dsa_caplint_services_map(d)
    dsa_caplint_pid_map(d, _map)
    dsa_caplint_cap_map(d, _map)

    with open(sca_raw_result_file(d, "caplint"), "w") as o:
        json.dump(_map, o)

    d.setVar("SCA_DATAMODEL_STORAGE", "{}/caplint.dm".format(d.getVar("T")))
    dm_output = do_dca_conv_caplint(d, _map)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "CAPLINT")
    sca_conv_deploy(d, "caplint")
    dca_deploy(d)
}

do_testimage[postfuncs] += "do_dca_caplint"
