FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# add mandatory BPF options to all qemu targets
SRC_URI:append:qemuall = " file://bpf.cfg"

# Auto load kheaders module
KERNEL_MODULE_AUTOLOAD:qemuall += "kheaders"
