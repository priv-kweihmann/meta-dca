## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

import os

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCAOpensnoop(OERuntimeTestCase):

    @OERequirePackage(['dca-opensnoop'])
    def test_dca_opensnoop_getlogs(self):
        self.target.copyFrom("/run/dca-opensnoop.log", os.path.join(self.tc.td.get('T'), "dca-opensnoop.log"))
