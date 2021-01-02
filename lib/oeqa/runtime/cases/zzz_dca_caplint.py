## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

import os

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCACaplint(OERuntimeTestCase):

    @OERequirePackage(['dca-caplint'])
    def test_dca_caplint_getlogs(self):
        self.target.copyFrom("/run/dca-caplint-capable.log", os.path.join(self.tc.td.get('T'), "dca-caplint-capable.log"))
