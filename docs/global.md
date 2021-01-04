# Global configuration

The behavior of the analysis can be controlled by several __bitbake__-variables

## Configuration

| var | purpose | type | default |
| ------------- |:-------------:| -----:| -----:|
| DCA_AUTO_SPARE | Layer names to be ignored for analysis | space-separated-string | "core yocto yoctobsp openembedded-layer clang-layer"
| DCA_AVAILABLE_MODULES | List of all available modules, use to globally enable/disable modules | space-separated-string | all available modules
| DCA_ENABLED_MODULES | The analysis modules to be activated on images | space-separated-string | same as `SCA_AVAILABLE_MODULES`
| DCA_SUPPRESSED_SERVICES | Services that should be ignored in analysis | space-separated-string | ""
| DCA_VERBOSE_OUTPUT | Verbose output of included tools | string: 0 or 1 | "0"
