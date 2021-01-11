## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

TEST_SUITES_append = " zzz_dca_mountdump"

def dca_module_mountdump_init(d):
    import json
    _map = []
    with open(os.path.join(d.getVar('T'), "dca-mountdump.json")) as i:
        _map = json.load(i)
    # return the list sorted by length of mount path
    # in inverse order
    return sorted(_map, key=lambda x: len(x["path"]), reverse=True)

def dca_module_mountdump(d, path):
    dca_module_mountdump.map = getattr(dca_module_mountdump, 'map', dca_module_mountdump_init(d))
    _bestmatch = {}
    for item in dca_module_mountdump.map:
        if path.startswith(item["path"]):
            return item
    return {}
