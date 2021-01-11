## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

inherit testimage
inherit sca-datamodel
inherit sca-helper
inherit sca-license-filter
inherit sca-suppress

inherit dca-image-backtrack
inherit dca-deploy

inherit dca-module-execsnoop
inherit dca-module-mountdump
inherit dca-module-systemddump
inherit dca-module-unlinksnoop

SCA_RAW_RESULT_FILE[filelife] = "json"

DCA_FILELIFE_DURATION_THRESHOLD ?= "10.0"
DCA_FILELIFE_ACCEPTABLE_FSTYPE ?= "bpf cgroup debugfs dev devpts devtmpfs mqueue proc sysfs tmpfs tracefs"

DCA_SUPPRESSION_INTERNAL += "dca-filelife.service"

TEST_SUITES_append = " zzz_dca_filelife"
IMAGE_INSTALL_append = " \
                        dca-filelife \
                        kernel-dev \
                        kernel-module-kheaders \
                       "

def dca_filelife_map(d, _map):
    import re

    _remove_list = []
    pattern = r"^\d+:\d+:\d+\s+(?P<pid>\d+)\s+(?P<app>.*?)\s+(?P<duration>\d+\.\d+)\s+(?P<file>.*)"
    with open(os.path.join(d.getVar('T'), "dca-filelife.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            _remove_list.append({
                "pid": m.group("pid"),
                "file": m.group("file"),
                "duration": float(m.group("duration"))
            })

    for k,v in _map.items():
        if "Filelife" not in v:
            v["Filelife"] = []
        for item in _remove_list:
            if item["pid"] in [v["MainPID"]] + v["Children"]:
                for f in [x for x in dca_module_unlinksnoop(d, item["pid"]) if x.endswith(item["file"])]:
                    v["Filelife"].append(
                                    {
                                        "files": f, 
                                        "duration": item["duration"],
                                        "fsinfo": dca_module_mountdump(d, f)
                                    }
                                )

def do_dca_conv_filelife(d, _map):
    import os
    import re

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")
    
    items = set()

    # create findings map
    _threshold = float(d.getVar("DCA_FILELIFE_DURATION_THRESHOLD"))
    _acceptable_ks = clean_split(d, "DCA_FILELIFE_ACCEPTABLE_FSTYPE")
    for k, v in _map.items():
        for item in v["Filelife"]:
            if item["duration"] < _threshold and item["fsinfo"]["fstype"] not in _acceptable_ks:
                items.add((v["FragmentPath"], 
                           "'{file}' had only a lifetime of {dur:.2f}s - consider writing the file to a ramdisk path".format(
                               file=item["files"], dur=item["duration"]
                           )))

    _suppress = sca_suppress_init(d, "SCA_FILELIFE_EXTRA_SUPPRESS", None)
    _findings = []

    for item in items:
        try:
            g = sca_get_model_class(d,
                                    PackageName=package_name,
                                    Tool="filelife",
                                    BuildPath=buildpath,
                                    File=item[0],
                                    Message=item[1],
                                    ID="filelife.filelife.shortlivedfile",
                                    Severity="warning")
            if _suppress.Suppressed(g):
                continue
            _findings += dca_backtrack_findings(d, g)
        except Exception as e:
            sca_log_note(d, str(e))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_dca_filelife() {
    import json

    # Get systemd dump map
    _map = dca_module_systemddump(d, 
                                  { 
                                    "Children": [],
                                    "FragmentPath": "/does/not/exist",
                                    "MainPID": "-1"
                                  },
                                  ["MainPID", "FragmentPath"])
    # Get children process PIDs from execsnoop
    for k, v in _map.items():
        v["Children"] = dca_module_execsnoop(d, v["MainPID"])
    # # # Map against seen capabilities
    dca_filelife_map(d, _map)

    with open(sca_raw_result_file(d, "filelife"), "w") as o:
        json.dump(_map, o)

    d.setVar("SCA_DATAMODEL_STORAGE", "{}/filelife.dm".format(d.getVar("T")))
    dm_output = do_dca_conv_filelife(d, _map)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    dca_deploy(d, "FILEINFO", "filelife")
}

do_testimage[postfuncs] += "do_dca_filelife"
