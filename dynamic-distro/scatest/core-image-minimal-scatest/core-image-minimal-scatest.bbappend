## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

TEST_SUITES = "aaa_dummy"

inherit dca

IMAGE_INSTALL += "packagegroup-dca-test"

do_testimage[depends] += "${PN}:do_image_complete"
