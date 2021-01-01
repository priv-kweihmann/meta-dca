## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

TEST_SUITES_append = " dca_systemddump"

def dca_module_systemddump_init(d, autofields, export):
    import json
    _map = {}
    with open(os.path.join(d.getVar('T'), "dca-systemddump.json")) as i:
        for k,v in json.load(i).items():

            _map[k] = { **autofields }
            for key in export:
                if key in ["CapabilityBoundingSet"]:
                    _map[k][key] = []
                    if key in v:
                        _map[k][key] = list(set([x.upper() for x in v[key].split(" ")]))
                elif key in v:
                    _map[k][key] = v[key]            
    return _map

def dca_module_systemddump(d, autofields, export):
    dca_module_systemddump.map = getattr(dca_module_systemddump, 'map', dca_module_systemddump_init(d, autofields, export))
    return dca_module_systemddump.map
