## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

import os
import json
import re

from oeqa.runtime.case import OERuntimeTestCase
from oeqa.core.decorator.depends import OETestDepends
from oeqa.runtime.decorator.package import OERequirePackage

class DCASystemdDump(OERuntimeTestCase):

    @OERequirePackage(['systemd'])
    def test_dca_systemddump(self):
        """Dumps information about all systemd units in json format
        """
        self.ignored_service = []
        with open(os.path.join(self.tc.td['T'], "dca-suppressed-services")) as i:
            self.ignored_service = json.load(i)
        status, output = self.target.run("systemctl list-units --no-pager --no-legend |" +
                                         " sed -e 's/^[[:space:]]*//' | cut -d' ' -f 1 |" +
                                         " sort | tr '\n' ' '")
        _result = {}
        for unit in output.split(" "):
            if not unit.endswith(".service"):
                continue
            if any(re.match(x, unit) for x in self.ignored_service):
                continue
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
