## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

inherit testimage
inherit sca-conv-to-export
inherit sca-datamodel
inherit sca-helper
inherit sca-license-filter
inherit sca-suppress

inherit dca-image-backtrack
inherit dca-deploy

inherit dca-module-execsnoop
inherit dca-module-systemddump

SCA_RAW_RESULT_FILE[opensnoop] = "json"

TEST_SUITES_append = " dca_opensnoop"
IMAGE_INSTALL_append = " \
                        dca-opensnoop \
                        kernel-dev \
                        kernel-module-kheaders \
                       "

def dca_opensnoop_map(d, _map):
    import re

    _filemap = {}
    pattern = r"^(?P<pid>\d+)\s+(?P<app>.*?)\s+(?P<fd>-*\d+)\s+\d+\s+(?P<mode>\d+)\s+(?P<path>.*)"
    with open(os.path.join(d.getVar('T'), "dca-opensnoop.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            if m.group("fd") == "-1":
                continue
            _pid = m.group("pid")
            if _pid not in _filemap:
                _filemap[_pid] = {"PathsRW": set(), "PathsRO": set()}
            _rawmode = int(m.group("mode"))
            _mode = [k for k,v in os.__dict__.items() if k.startswith("O_") and v & _rawmode]
            if any(x in _mode for x in ["O_WRONLY", "O_RDWR"]):
                _filemap[_pid]["PathsRW"].add(m.group("path"))
            else:
                _filemap[_pid]["PathsRO"].add(m.group("path"))

    for k,v in _map.items():
        if "PathsRW" not in v:
            v["PathsRW"] = []
        if "PathsRO" not in v:
            v["PathsRO"] = []
        for x in [v["MainPID"]] + v["Children"]:
            if x in _filemap:
                v["PathsRW"] = list(set(v["PathsRW"] + list(_filemap[x]["PathsRW"])))
                v["PathsRO"] = list(set(v["PathsRO"] + list(_filemap[x]["PathsRO"])))

def do_dca_conv_opensnoop(d, _map):
    import os
    import re

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")
    
    # Create findings map
    _res = {
        "unusedro": {"items": [], "msg": "'{}' is set in 'ReadOnlyPaths' but is not used"},
        "unusedrw": {"items": [], "msg": "'{}' is set in 'ReadWritePaths' but is not used for writing"},
        "notsetro": {"items": [], "msg": "'{}' is used R/O but is not set in 'ReadOnlyPaths'"},
        "notsetrw": {"items": [], "msg": "'{}' is used R/W but is not set in 'ReadWritePaths'"},
    }
    for k, v in _map.items():
        for _path in v["ReadOnlyPaths"]:
            if not any(x.startswith(_path) for x in v["PathsRO"]):
                _res["unusedro"]["items"].append((v["FragmentPath"], _path))
        for _path in v["ReadWritePaths"]:
            if not any(x.startswith(_path) for x in v["PathsRW"]):
                _res["unusedrw"]["items"].append((v["FragmentPath"], _path))
        for _path in v["PathsRO"]:
            if not any(_path.startswith(x) for x in v["ReadOnlyPaths"]):
                _res["notsetro"]["items"].append((v["FragmentPath"], _path))
        for _path in v["PathsRW"]:
            if not any(_path.startswith(x) for x in v["ReadWritePaths"]):
                _res["notsetrw"]["items"].append((v["FragmentPath"], _path))

    items = []

    _suppress = sca_suppress_init(d, "SCA_OPENSNOOP_EXTRA_SUPPRESS", None)
    _findings = []

    for k, v in _res.items():
        for item in v["items"]:
            try:
                g = sca_get_model_class(d,
                                        PackageName=package_name,
                                        Tool="opensnoop",
                                        BuildPath=buildpath,
                                        File=item[0],
                                        Message=v["msg"].format(item[1]),
                                        ID="opensnoop.opensnoop.{}".format(k),
                                        Severity="warning")
                if _suppress.Suppressed(g):
                    continue
                _findings += dca_backtrack_findings(d, g)
            except Exception as e:
                sca_log_note(d, str(e))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_dca_opensnoop() {
    import json

    # Get systemd dump map
    _map = dca_module_systemddump(d, 
                                  { 
                                    "Children": [],
                                    "FragmentPath": "/does/not/exist",
                                    "MainPID": "-1",
                                    "PathsRO": [],
                                    "PathsRW": []
                                  },
                                  ["MainPID", "FragmentPath", 
                                   "ReadOnlyPaths", "ReadWritePaths"])
    # Get children process PIDs from execsnoop
    for k, v in _map.items():
        v["Children"] = dca_module_execsnoop(d, v["MainPID"])
    # # Map against seen capabilities
    dca_opensnoop_map(d, _map)

    with open(sca_raw_result_file(d, "opensnoop"), "w") as o:
        json.dump(_map, o)

    d.setVar("SCA_DATAMODEL_STORAGE", "{}/opensnoop.dm".format(d.getVar("T")))
    dm_output = do_dca_conv_opensnoop(d, _map)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    sca_task_aftermath(d, "OPENSNOOP")
    sca_conv_deploy(d, "opensnoop")
    dca_deploy(d)
}

do_testimage[postfuncs] += "do_dca_opensnoop"
