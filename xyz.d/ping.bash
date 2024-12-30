
ping_init () {
	PING_HOSTS=()

	xyzcfg PING_HOSTS "List of hosts to ping"
	xyzenv PING_TIMES "Times for each host ping"
	xyzfun PING_LIST "Formatted output of: * PING_TIMES|PING_HOSTS"
}

ping_set () {
	PING_TIMES=()

	local _HOST
	for _HOST in ${PING_HOSTS[@]}; do
		info "pinging $_HOST"
        	local _TIME="$(ping -c 1 $_HOST | grep "time=" | sed -r 's/.*time=(.+) ms/\1/')"
		PING_TIMES+=("${_TIME}ms")
	done
}

PING_LIST () {
	for (( i=0; i<${#PING_HOSTS[@]}; i++ )); do
		echo "* ${PING_TIMES[$i]}|${PING_HOSTS[$i]}"
	done
}
