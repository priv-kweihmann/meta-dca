## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

import os

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCAFilelife(OERuntimeTestCase):

    @OERequirePackage(['dca-filelife'])
    def test_dca_filelife_getlogs(self):
        self.target.copyFrom("/run/dca-filelife.log", os.path.join(self.tc.td.get('T'), "dca-filelife.log"))
