
uname_init () {
	xyzenv UNAME_KERNEL_RELEASE "Kernel release"
	xyzenv UNAME_KERNEL_VERSION "Kernel version"
	xyzenv UNAME_OS "OS name"
	xyzenv UNAME_MACHINE "CPU Architecture"
}

uname_set () {
	UNAME_KERNEL_RELEASE="$(uname -r)"
	UNAME_KERNEL_VERSION="$(uname -v)"
	UNAME_OS="$(uname -o)"
	UNAME_MACHINE="$(uname -m)"
}

