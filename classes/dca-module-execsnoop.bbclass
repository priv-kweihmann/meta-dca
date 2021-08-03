## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

DCA_SUPPRESSION_INTERNAL += "dca-execsnoop.service"

TEST_SUITES:append = " zzz_dca_execsnoop"

def dca_module_execsnoop_init(d):
    import re
    pattern = r"^(\w+)\s+(?P<pid>\d+)\s+(?P<ppid>\d+)\s+\d+\s+.*"

    _initial_map = {}
    # Initial loop
    with open(os.path.join(d.getVar('T'), "dca-execsnoop.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            if not m.group("ppid") in _initial_map:
                _initial_map[m.group("ppid")] = []
            _initial_map[m.group("ppid")].append(m.group("pid"))

    def _maploop(_id, _m):
        res = []
        if _id in _m:
            res += _m[_id]
            for v in _m[_id]:
                res += _maploop(v, _m)
        return res

    return {k:_maploop(k, _initial_map) for k,_ in _initial_map.items()}

def dca_module_execsnoop(d, pid):
    dca_module_execsnoop.map = getattr(dca_module_execsnoop, 'map', dca_module_execsnoop_init(d))
    if pid in dca_module_execsnoop.map:
        return dca_module_execsnoop.map[pid]
    return []
