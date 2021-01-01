## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

SCA_SUPPRESS_LOCALS_append = "\
    lib/systemd/system/dca-caplint-capable.service,caplint.caplint.*,*,* \
    lib/systemd/system/dca-execsnoop.service,caplint.caplint.*,*,* \
    "