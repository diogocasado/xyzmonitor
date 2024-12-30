
net_init () {
	NET_DEVS=()

	xyzcfg NET_DEVS "Network ifaces to be monitored"
	xyzenv NET_INET "IPv4 address for each iface"
	xyzenv NET_INET6 "IPv6 address for each iface"
	xyzenv NET_ETHER "MAC address for each iface"
	xyzenv NET_RATE_RX "Download rate for each iface"
	xyzenv NET_RATE_TX "Upload rate for each iface"
	xyzfun NET_LIST "Formatted out list of * NET_DEVS|NET_INET|NET_RATE_RX|NET_RATE_TX"
}

net_scale_bps () {
	local _VALUE=$(echo "$1*8" | bc -l)

	local _SCALES=("" "K" "M" "G" "T")
	local _PRECISION=(0 0 1 2 3)
	local _SCALE=0

	while [[ ${_VALUE%.*} -ge 1000 ]]; do
		_VALUE=$(echo "$_VALUE/1000" | bc -l);
		let _SCALE++
	done

	printf "%.*f%sbps" ${_PRECISION[$_SCALE]} $_VALUE "${_SCALES[$_SCALE]}"
}

net_set () {

	NET_INET=()
	NET_INET6=()
	NET_ETHER=()
	NET_RATE_TX=()
	NET_RATE_RX=()

	local _NOW=$(date -u +%s)
	local _NETSTAT="$(netstat -ie)"

	local _SAMPLE_FILE=/tmp/xyznet.out
	local _SAMPLE_TIME
	local _SAMPLE_NETSTAT
	local _SAMPLE_DIFF

	if [[ -f $_SAMPLE_FILE ]]; then
		_SAMPLE_TIME=$(cat $_SAMPLE_FILE | head -n 1)
		_SAMPLE_NETSTAT=$(awk 'FNR > 1' $_SAMPLE_FILE)
		_SAMPLE_DIFF=$(($_NOW - $_SAMPLE_TIME))
	fi

	local _DEV_N=0
	local _DEV
	for _DEV in ${NET_DEVS[@]}; do

		info "set $_DEV"

		local _DEV_NETSTAT=$(echo "$_NETSTAT" | grep -A 7 $_DEV)
		if [[ -n ${_DEV_NETSTAT:+x} ]]; then
			local _INET=$(echo "$_DEV_NETSTAT" | grep "inet\\s" | awk '{print $2}')
			local _INET6=$(echo "$_DEV_NETSTAT" | grep "inet6\\s" | awk '{print $2}')
			local _ETHER=$(echo "$_DEV_NETSTAT" | grep "ether\\s" | awk '{print $2}')

			NET_INET+=("$_INET")
			NET_INET6+=("$_INET")
			NET_ETHER+=("$_ETHER")

			if [[ -n ${_SAMPLE_NETSTAT:+x} ]]; then
				local _DEV_SAMPLE_NETSTAT=$(echo "$_SAMPLE_NETSTAT" | grep -A 7 $_DEV)
				local _SAMPLE_RX=$(echo "$_DEV_SAMPLE_NETSTAT" | grep "RX packets" | awk '{print $5}')
				local _SAMPLE_TX=$(echo "$_DEV_SAMPLE_NETSTAT" | grep "TX packets" | awk '{print $5}')

				local _CURR_RX=$(echo "$_DEV_NETSTAT" | grep "RX packets" | awk '{print $5}')
				local _CURR_TX=$(echo "$_DEV_NETSTAT" | grep "TX packets" | awk '{print $5}')

				local _RATE_RX=$(echo "scale=0; ($_CURR_RX-$_SAMPLE_RX)/$_SAMPLE_DIFF" | bc -l)
				local _RATE_TX=$(echo "scale=0; ($_CURR_TX-$_SAMPLE_TX)/$_SAMPLE_DIFF" | bc -l)

				NET_RATE_RX+=("$(net_scale_bps $_RATE_RX)")
				NET_RATE_TX+=("$(net_scale_bps $_RATE_TX)")
			else
				NET_RATE_RX+=($NULL)
				NET_RATE_TX+=($NULL)
			fi

		else
			NET_INET+=($NULL)
			NET_INET6+=($NULL)
			NET_ETHER+=($NULL)
			NET_RATE_RX+=($NULL)
			NET_RATE_TX+=($NULL)
		fi

		let _DEV_N+=1
	done

	echo $_NOW > $_SAMPLE_FILE
	netstat -ie >> $_SAMPLE_FILE
}

NET_LIST () {
	for (( i=0; i<${#NET_DEVS[@]}; i++ )); do
		echo "* ${NET_DEVS[$i]}|${NET_INET[$i]}|${NET_RATE_RX[$i]}|${NET_RATE_TX[$i]}"
	done
}

