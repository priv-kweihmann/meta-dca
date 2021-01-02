## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2021, Konrad Weihmann

from oeqa.runtime.case import OERuntimeTestCase

class DCADummyTest(OERuntimeTestCase):

    def test_dummy(self):
        """This test does literally nothing but sleep
        """
        self.target.run("sleep 15")
