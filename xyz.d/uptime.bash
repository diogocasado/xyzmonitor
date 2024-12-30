
uptime_init () {
	xyzenv UPTIME "Up time, duh"
}

uptime_set () {
	UPTIME="$(uptime -p)"
}

