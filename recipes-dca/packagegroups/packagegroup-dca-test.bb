SUMMARY = "Packagegroup for testing dca-integration"

inherit packagegroup

RDEPENDS_${PN} += "\
                    dca-caplint-test-service \
                    dca-filelife-test-service \
                    dca-opensnoop-test-service \
                  "
