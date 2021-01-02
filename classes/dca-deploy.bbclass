## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

inherit sca-conv-to-export
inherit sca-helper

# as we can't work with sstate-cache here, we have to manually invoke the deployment
def _dca_deploy(d):
    import os
    import shutil

    for x in clean_split(d, "DCA_ACTIVE_MODULES"):
        _src = os.path.join(d.getVar("SCA_FINDINGS_DIR"), x)
        _dst = os.path.join(d.getVar("SCA_EXPORT_DIR"), x)
        if not os.path.exists(_src):
            continue
        shutil.copytree(_src, _dst, dirs_exist_ok=True)

def dca_deploy(d, toolname, id):
    sca_task_aftermath(d, "CAPLINT")
    sca_conv_deploy(d, "caplint")
    _dca_deploy(d)
    # reset DATAMODEL
    d.setVar("__SCA_DATAMODEL_STORAGE", "[]")
