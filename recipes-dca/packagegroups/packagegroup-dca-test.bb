SUMMARY = "Packagegroup for testing dca-integration"

inherit packagegroup

RDEPENDS_${PN} += "\
                    dca-caplint-test-service \
                    dca-opensnoop-test-service \
                  "
