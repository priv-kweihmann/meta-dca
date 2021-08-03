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
inherit dca-module-systemddump

SCA_RAW_RESULT_FILE[filemiss] = "json"

DCA_SUPPRESSION_INTERNAL += "dca-opensnoop.service"

TEST_SUITES:append = " zzz_dca_opensnoop"
IMAGE_INSTALL:append = " \
                        dca-opensnoop \
                       "

def dca_filemiss_map(d, _map):
    import re

    _filemap = {}
    pattern = r"^(?P<pid>\d+)\s+(?P<app>.*?)\s+(?P<fd>-*\d+)\s+(?P<err>\d+)\s+(?P<mode>\d+)\s+(?P<path>.*)"
    with open(os.path.join(d.getVar('T'), "dca-opensnoop.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            if m.group("fd") != "-1":
                continue
            _pid = m.group("pid")
            if _pid not in _filemap:
                _filemap[_pid] = set()
            _filemap[_pid].add((m.group("path"), int(m.group("err"))))

    for k,v in _map.items():
        for x in [v["MainPID"]] + v["Children"]:
            if x in _filemap:
                v["FileMiss"] = {y[0]: y[1] for y in _filemap[x]}

def do_dca_conv_filemiss(d, _map):
    import os
    import errno
    import re

    package_name = d.getVar("PN")
    buildpath = d.getVar("SCA_SOURCES_DIR")
    
    _suppress = sca_suppress_init(d, "SCA_OPENSNOOP_EXTRA_SUPPRESS", None)
    _findings = []

    for service, v in _map.items():
        for _file, _errno in v["FileMiss"].items():
            try:
                g = sca_get_model_class(d,
                                        PackageName=package_name,
                                        Tool="filemiss",
                                        BuildPath=buildpath,
                                        File=service,
                                        Message="File '{_file}' can't be accessed because of '{errno}'".format(_file=_file, errno=os.strerror(_errno)),
                                        ID="filemiss.filemiss.{}".format(errno.errorcode[_errno]),
                                        Severity="warning")
                if _suppress.Suppressed(g):
                    continue
                _findings += dca_backtrack_findings(d, g)
            except Exception as e:
                sca_log_note(d, str(e))

    sca_add_model_class_list(d, _findings)
    return sca_save_model_to_string(d)

python do_dca_filemiss() {
    import json

    # Get systemd dump map
    _map = dca_module_systemddump(d, 
                                  { 
                                    "Children": [],
                                    "FragmentPath": "/does/not/exist",
                                    "MainPID": "-1",
                                    "FileMiss": {},
                                  },
                                  ["MainPID", "FragmentPath"])
    # Get children process PIDs from execsnoop
    for k, v in _map.items():
        v["Children"] = dca_module_execsnoop(d, v["MainPID"])
    # Map against missed files
    dca_filemiss_map(d, _map)

    with open(sca_raw_result_file(d, "filemiss"), "w") as o:
        json.dump(_map, o)

    d.setVar("SCA_DATAMODEL_STORAGE", "{}/filemiss.dm".format(d.getVar("T")))
    dm_output = do_dca_conv_filemiss(d, _map)
    with open(d.getVar("SCA_DATAMODEL_STORAGE"), "w") as o:
        o.write(dm_output)

    dca_deploy(d, "FILEMISS", "filemiss")
}

do_testimage[postfuncs] += "do_dca_filemiss"
