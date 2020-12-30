## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

# as we can't work with sstate-cache here, we have to manually invoke the deployment
def dca_deploy(d):
    import os
    import shutil

    for x in clean_split(d, "DCA_ACTIVE_MODULES"):
        _src = os.path.join(d.getVar("SCA_FINDINGS_DIR"), x)
        _dst = os.path.join(d.getVar("SCA_EXPORT_DIR"), x)
        if not os.path.exists(_src):
            continue
        shutil.copytree(_src, _dst, dirs_exist_ok=True)
