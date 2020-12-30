FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# add mandatory BPF options to all qemu targets
SRC_URI_append_qemuall = " file://bpf.cfg"

# Auto load kheaders module
KERNEL_MODULE_AUTOLOAD_qemuall += "kheaders"
