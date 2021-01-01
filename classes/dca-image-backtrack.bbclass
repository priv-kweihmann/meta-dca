## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

## Backtrack findings from image to the original recipes

inherit sca-license-image-helper

def dca_backtrack_image_init(d):
    import json
    import glob
    import oe.packagedata

    with open(d.getVar("SCA_IMAGE_PKG_LIST")) as i:
        pack_list = json.load(i)

    _result = {}

    _map = {}
    for item in glob.glob(os.path.join(d.getVar("PKGDATA_DIR"), "runtime", "*")):
        x = oe.packagedata.read_subpkgdata_dict(os.path.basename(item), d)
        if "PKG" in x:
            _map[x["PKG"]] = os.path.basename(item)

    for item in pack_list.keys():
        _item = _map[item] if item in _map else item
        pkgdata = oe.packagedata.read_subpkgdata_dict(_item, d)
        if "FILES_INFO" in pkgdata:
            file_list = pkgdata["FILES_INFO"]
            if isinstance(file_list, str):
                import ast
                file_list = ast.literal_eval(file_list)

            for n in file_list.keys():
                _recipe = oe.packagedata.recipename(_item, d)
                _rawpath = "${{BASE_WORKDIR}}/{arch}${{TARGET_VENDOR}}-${{TARGET_OS}}/{recipe}/{version}/image/".format(
                            arch=pack_list[item]["arch"],
                            recipe=_recipe,
                            version=pack_list[item]["ver"].replace(":", "_")
                )
                _result[n.lstrip("/")] = (_recipe, d.expand(_rawpath))
    return _result

# Adds additional findings if the findings can be backtracked
# to a recipe
def dca_backtrack_findings(d, g):
    import copy
    res = [g]
    dca_backtrack_findings.map = getattr(dca_backtrack_findings, 'map', dca_backtrack_image_init(d))
    if g.File.lstrip("/") in dca_backtrack_findings.map:
        h = copy.deepcopy(g)
        h.PackageName, h.BuildPath = dca_backtrack_findings.map[h.File.lstrip("/")]
        bb.debug(1, "Backtracked to {} -> {}".format(h.PackageName, h.BuildPath))
        res.append(h)
    return res
