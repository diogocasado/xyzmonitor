
hostname_init () {
	xyzenv HOSTNAME "Host name"
}

hostname_set () {
	HOSTNAME="$(hostname -f)"
}

