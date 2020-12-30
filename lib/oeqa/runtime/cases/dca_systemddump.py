## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

import os
import json

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCASystemdDump(OERuntimeTestCase):

    @OERequirePackage(['systemd'])
    def test_dca_systemddump(self):
        """Dumps information about all systemd units in json format
        """
        status, output = self.target.run("systemctl list-unit-files --no-pager --no-legend | cut -d' ' -f 1 | sort | tr '\n' ' '")
        _result = {}
        for unit in output.split(" "):
            status, output = self.target.run("systemctl show --all {}".format(unit))
            _result[unit] = {}
            for line in output.split("\n"):
                if "=" not in line:
                    continue
                _chunks = line.strip("\n").split("=")
                if len(_chunks) > 1:
                    _key = _chunks[0]
                    _value = _chunks[1]
                else:
                    _key = _chunks[0]
                    _value = ""
                _result[unit][_key] = _value
        with open(os.path.join(self.tc.td.get('T'), "dca-systemddump.json"), "w") as o:
            json.dump(_result, o)
