## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

import os
import json
import re

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCAMountDump(OERuntimeTestCase):

    def test_dca_mountdump(self):
        """Dumps information about mounted paths and fs types
        """
        status, output = self.target.run("mount -l")
        _result = []
        _pattern = r"^(?P<type>.*?)\s+on\s+(?P<path>.*?)\s+type\s+(?P<fstype>\w+)\s+\((?P<options>.*)\)"
        for m in re.finditer(_pattern, output, re.MULTILINE):
            _t = m.groupdict()
            _t["options"] = _t["options"].split(",")
            _result.append(_t)
        with open(os.path.join(self.tc.td.get('T'), "dca-mountdump.json"), "w") as o:
            json.dump(_result, o)
