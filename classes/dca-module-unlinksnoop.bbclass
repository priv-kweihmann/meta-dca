## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

DCA_SUPPRESSION_INTERNAL += "dca-unlinksnoop.service"

TEST_SUITES_append = " zzz_dca_unlinksnoop"

def dca_module_unlinksnoop_init(d):
    import re
    pattern = r"^(?P<pid>\d+)\s+(?P<ret>\d+)\s+(?P<path>.*)"

    _map = {}
    # Initial loop
    with open(os.path.join(d.getVar('T'), "dca-unlinksnoop.log")) as i:
        for m in re.finditer(pattern, i.read(), re.MULTILINE):
            if m.group("ret") != "0":
                continue
            _pid = m.group("pid")
            if _pid not in _map:
                _map[_pid] = set()
            _map[_pid].add(m.group("path"))
    return _map

def dca_module_unlinksnoop(d, pid):
    dca_module_unlinksnoop.map = getattr(dca_module_unlinksnoop, 'map', dca_module_unlinksnoop_init(d))

    if pid in dca_module_unlinksnoop.map:
        return sorted(list(dca_module_unlinksnoop.map[pid]))
    return []
