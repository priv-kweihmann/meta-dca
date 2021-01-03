## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

# local storage
DCA_RECIPE_BACKTRACK_LOCAL ?= "${WORKDIR}/recipe-backtrack"
# global storage
DCA_RECIPE_BACKTRACK_DEPLOY ?= "${DEPLOY_DIR}/recipe-backtrack"

# This class creates info for the used recipes files
python do_dca_recipe_backtrack_deploy() {
    import os
    import json
    _files = [x for x in d.getVar("BBINCLUDED").split(" ")]
    for _layerroot in [x for x in d.getVar("BBLAYERS").split(" ") if x] + [d.getVar("TOPDIR")]:
        if not _layerroot.endswith("/"):
            _layerroot += "/"
        for index, _file in enumerate(_files):
            _files[index] = _file.replace(_layerroot, "", 1)

    _files = sorted(list(set([x.lstrip("/") for x in _files])))
    os.makedirs(d.getVar("DCA_RECIPE_BACKTRACK_LOCAL"), exist_ok=True)
    with open(d.expand("${DCA_RECIPE_BACKTRACK_LOCAL}/${PN}-${PV}.json"), "w") as o:
        json.dump(_files, o)
}

do_dca_recipe_backtrack_deploy[doc] = "Provides info on the used recipe files for a package"
do_dca_recipe_backtrack_deploy[cardepsexclude] = "BBINCLUDED BBLAYERS TOPDIR"
do_dca_recipe_backtrack_deploy[dirs] = "${DCA_RECIPE_BACKTRACK_LOCAL}"
do_dca_recipe_backtrack_deploy[cleandirs] = "${DCA_RECIPE_BACKTRACK_LOCAL}"
do_dca_recipe_backtrack_deploy[sstate-inputdirs] = "${DCA_RECIPE_BACKTRACK_LOCAL}"
do_dca_recipe_backtrack_deploy[sstate-outputdirs] = "${DCA_RECIPE_BACKTRACK_DEPLOY}/"
do_dca_recipe_backtrack_deploy[stamp-extra-info] = "${MACHINE_ARCH}"

addtask do_dca_recipe_backtrack_deploy before do_build

SSTATETASKS += "do_dca_recipe_backtrack_deploy"

python do_dca_recipe_backtrack_deploy_setscene() {
    sstate_setscene(d)
}
addtask do_dca_recipe_backtrack_deploy_setscene
