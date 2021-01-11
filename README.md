# Table of content <!-- omit in toc -->

- [meta-dca](#meta-dca)
- [Requirements](#requirements)
- [How to use this layer](#how-to-use-this-layer)
  - [Additional notes](#additional-notes)
- [Getting started](#getting-started)
- [Available modules](#available-modules)
- [Further documentation](#further-documentation)
- [Get involved](#get-involved)
- [Security Policy](#security-policy)

## meta-dca

This layer is an addition to [meta-sca](https://github.com/priv-kweihmann/meta-sca). It enables **dynamic code analysis**, such as

- checking capabilties
- memleak checking
- files/path checking

These checks are suppose to be done on the build host only (using `qemu`/`testimage` support)

## Requirements

You need the following to use *meta-dca*

- [clang](https://github.com/kraj/meta-clang)
- [meta-sca](https://github.com/priv-kweihmann/meta-sca)
- [openembedded](http://cgit.openembedded.org/meta-openembedded/)
- [poky](https://git.yoctoproject.org/cgit/cgit.cgi/poky)

- a sufficient `oeqa` based test suite
- `systemd` set in `DISTRO_FEATURES`

## How to use this layer

As the name implies, this layer uses dynamic code analysis to check certain (configurable features), so we have to execute the code that needs to be checked. Therefore we are using `testimage` provided by upstream **poky**.
The checks itself will **only** be done when you execute `bitbake <your-image-recipe> -c testimage`.
Results will be stored in the way [meta-sca](https://github.com/priv-kweihmann/meta-sca) was configured for the build

### Additional notes

It's highly recommended to

- enable **KVM** support (`QEMU_USE_KVM = "1"`)
- have at least 1G of RAM for QEMU (`QB_MEM = "-m 1024"`)

## Getting started

For a quick start how to use this layer see [getting started guide](docs/getting_started.md)

## Available modules

| module    | purpose                                                      | more info                           |
| --------- | ------------------------------------------------------------ | ----------------------------------- |
| caplint   | Identify needed capabilities of a systemd unit               | https://github.com/iovisor/bcc      |
| filelife  | Find shortlived files written to non-volatile storage        | https://github.com/iovisor/bcc      |
| opensnoop | Lint ReadOnlyPaths/ReadWritePaths settings of a systemd unit | https://github.com/iovisor/bpftrace |

## Further documentation

- [Global Configuration](docs/global.md)
  - [filelife](docs/filelife.md)

## Get involved

To get involved following things can be done

- create an issue
- fix an issue and create a pull request
- see the pinned issues in the [bugtracker](https://github.com/priv-kweihmann/meta-dca/issues)

## Security Policy

For the project's security policy please see [here](SECURITY.md)
