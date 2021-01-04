## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

inherit dca-suppression

TEST_SUITES_append = " zzz_dca_systemddump"

def dca_module_systemddump(d, autofields, export):
    import json
    _map = {}
    with open(os.path.join(d.getVar('T'), "dca-systemddump.json")) as i:
        for k,v in json.load(i).items():

            _map[k] = { **autofields }
            for key in export:
                if key in ["CapabilityBoundingSet"]:
                    _map[k][key] = []
                    if key in v:
                        _map[k][key] = list(set([x.upper() for x in v[key].split(" ") if x]))
                elif key in ["ReadOnlyPaths", "ReadWritePaths"]:
                    _map[k][key] = []
                    if key in v:
                        _map[k][key] = list(set([x for x in v[key].split(" ") if x]))
                elif key in v:
                    _map[k][key] = v[key]            
    return _map

python dca_force_suppressions_expand() {
    import json
    import re

    _list = set(dca_get_suppressed_service_list(d))
    _list.update(clean_split(d, "DCA_SUPPRESSION_INTERNAL"))
    _list = set([re.escape(x) for x in _list])
    _list = set([x.replace("@\.", "@.*\.") for x in _list])
    with open(d.expand("${T}/dca-suppressed-services"), "w") as o:
        json.dump(list(_list), o)
}

do_testimage[prefuncs] += "dca_force_suppressions_expand"
