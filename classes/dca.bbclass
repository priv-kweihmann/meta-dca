## SPDX-License-Identifier: BSD-2-Clause
## Copyright (c) 2020, Konrad Weihmann

inherit sca-helper
inherit dca-default-suppression

DCA_AVAILABLE_MODULES ??= "\
                           caplint \
                          "
DCA_ENABLED_MODULES ??= "${DCA_AVAILABLE_MODULES}"
DCA_VERBOSE_OUTPUT ??= "0"

addhandler dca_invoke_handler
dca_invoke_handler[eventmask] = "bb.event.RecipePreFinalise"
python dca_invoke_handler() {
    import bb
    from bb.parse.parse_py import BBHandler
    enabledModules = []
    if not bb.data.inherits_class('image', d):
        bb.fatal("dca.bbclass can only be used on images")
    for item in intersect_lists(d, d.getVar("DCA_ENABLED_MODULES"), d.getVar("DCA_AVAILABLE_MODULES")):
        try:
            BBHandler.inherit("dca-{}".format(item), "dca-on-image", 1, d)
            func = "dca-{}-init".format(item).replace("-", "_")
            if d.getVar(func, False) is not None:
                bb.build.exec_func(func, d, **get_bb_exec_ext_parameter_support(d))
            okay = True
            enabledModules.append(item)
        except bb.parse.ParseError as exp:
            if d.getVar("DCA_VERBOSE_OUTPUT") != "0":
                bb.note(d, str(exp))
    if any(enabledModules):
        if d.getVar("DCA_VERBOSE_OUTPUT") == "1":
            bb.note("Using DCA Module(s) {}".format(",".join(sorted(enabledModules))))
    d.setVar("DCA_ACTIVE_MODULES", " ".join(sorted(enabledModules)))
}
