## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

inherit sca-license-filter
inherit sca-helper
inherit dca-recipe-backtrack

def _dca_get_services(d, item):
    file_list = item["__FILES_INFO"]
    if isinstance(file_list, str):
        import ast
        file_list = ast.literal_eval(file_list)
    res = [x for x in file_list.keys() if x.endswith(".service")]
    file_list = item["FILES_INFO"]
    if isinstance(file_list, str):
        import ast
        file_list = ast.literal_eval(file_list)
    res += [x for x in file_list.keys() if x.endswith(".service")]
    return list(set(res))

def _dca_is_valid_license(d, item):
    return sca_license_filter_match(d, item["LICENSE"])

def _dca_is_not_blacklised(d, item):
    import re
    
    return not any(re.match(x, item["PN"]) for x in clean_split(d, "SCA_BLACKLIST"))

def _dca_is_from_valid_path(d, item):
    _used_layer = clean_split(d, "BBFILE_COLLECTIONS")
    _spared_layer = set(clean_split(d, "SCA_SPARE_LAYER") + clean_split(d, "DCA_AUTO_SPARE"))

    _available_layer = [x for x in _used_layer if x not in _spared_layer]
    _valid_paths = [d.getVar("BBFILE_PATTERN_{}".format(x)).lstrip("^").rstrip("/") or "" for x in _available_layer]
    _spare_dirs = [x for x in clean_split(d, "SCA_SPARE_DIRS")]
    _files = []
    for x in item["__RECIPEFILES"]:
        for v in _valid_paths:
            _path = os.path.join(v, x)
            if os.path.exists(_path):
                if d.getVar("SCA_SPARE_IGNORE_BBAPPEND") == "1" and _path.endswith(".bbappend"):
                    continue
                if any(_path.startswith(y) for y in _spare_dirs):
                    continue
                return True
    return False

def _dca_translate_pkgname(d, name):
    import glob

    if oe.packagedata.recipename(name, d):
        return name
    for item in glob.glob(os.path.join(d.getVar("PKGDATA_DIR"), "runtime", "*")):
        x = oe.packagedata.read_subpkgdata_dict(os.path.basename(item), d)
        if "PKG" in x:
            return oe.packagedata.recipename(x["PKG"], d)
    return None

def _dca_get_recipe_backtrack(d, _map):
    import json
    import oe.packagedata

    res = {}

    _backtrack_mask = [".bbappend", ".bb"]

    for k,v in _map.items():
        try:
            _key = _dca_translate_pkgname(d, k)
            if not _key:
                bb.note("{} can't be translated to a recipe".format(_key))
                continue
            try:
                _org_files_info = oe.packagedata.read_subpkgdata_dict(k, d)["FILES_INFO"]
            except:
                _org_files_info = {}
            v = {**v, 
                 **oe.packagedata.read_subpkgdata_dict(oe.packagedata.recipename(_key, d), d)}
            v["__FILES_INFO"] = _org_files_info
            if not all(x in v for x in ["PN", "PV"]):
                bb.note("No package info available {}".format(_key))
                continue
            res[_key] = v
            _path = d.expand("${{DCA_RECIPE_BACKTRACK_DEPLOY}}/{PN}-{PV}.json".format(PN=v["PN"], PV=v["PV"]))
            if os.path.exists(_path):
                with open(_path) as i:
                    _j = json.load(i)
                    res[_key]["__RECIPEFILES"] = [x for x in _j if any(x.endswith(y) for y in _backtrack_mask)]
            else:
                res[_key]["__RECIPEFILES"] = []
                bb.note("No recipe-backtrack available for {}".format(_key))
        except Exception as e:
            bb.warn(str(e))
            pass
    return res

def _dca_get_image_packages(d):
    import json

    _image_package_list = {}
    with open(d.getVar("SCA_IMAGE_PKG_LIST")) as i:
        _image_package_list = json.load(i)
    return _image_package_list

def dca_get_suppressed_service_list(d):
    import os
    _map = _dca_get_image_packages(d)
    _map = _dca_get_recipe_backtrack(d, _map)

    _mask_list = set()

    for k,v in _map.items():
        if not all([_dca_is_not_blacklised(d, v),
                _dca_is_valid_license(d, v),
                _dca_is_from_valid_path(d, v)]):
            _mask_list.update(_dca_get_services(d, v))
    return sorted([os.path.basename(x) for x in _mask_list])
