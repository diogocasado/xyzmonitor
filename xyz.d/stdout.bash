
stdout_init () {
	STDOUT_COLUMN_SEP="|"
	STDOUT_TEMPLATE_FILE=
	STDOUT_TEMPLATE=()

	STDOUT_TEMPLATE+="$(cat <<-'EOF'
		Hostname|$HOSTNAME
		Uptime|$UPTIME
		Kernel|$UNAME_KERNEL_RELEASE
		Load\|LOADAVG_1_5_15
		Memory|$MEM_USED of $MEM_TOTAL
		Network
		|${NET_DEVS[0]}: ${NET_INET[0]} Rx ${NET_RATE_RX[0]}, Tx ${NET_RATE_TX[0]}
		|${NET_DEVS[1]}: ${NET_INET[1]} Rx ${NET_RATE_RX[1]}, Tx ${NET_RATE_TX[1]}
		Storage
		|${FS_MNTS[0]}: ${FS_USE[0]} of ${FS_SIZE[0]}
		|${FS_MNTS[1]}: ${FS_USE[1]} of ${FS_SIZE[1]}
		EOF
	)"

	xyzcfg STDOUT_COLUMN_SEP "Column separator for table format"
	xyzcfg STDOUT_TEMPLATE_FILE "Standard output template file to read from"
	xyzcfg STDOUT_TEMPLATE "Standard output template"
}

stdout_prenv () {

	local _TEMPLATE_FILE="$(realpath $CONF_DIR/$STDOUT_TEMPLATE_FILE)"
	if [[ -n "$_TEMPLATE_FILE" ]]; then
		if [[ -f "$_TEMPLATE_FILE" ]]; then
			info "Using template file: $_TEMPLATE_FILE"
			STDOUT_TEMPLATE=("$(cat $_TEMPLATE_FILE)")
		else
			error "Couldn't open $_TEMPLATE_FILE"
		fi
	fi
}

stdout_writeenv () {
	STDOUT=

	local _TEMPLATE
	for _TEMPLATE in "${STDOUT_TEMPLATE[@]}"; do
		if [[ -n "$STDOUT" ]]; then
			STDOUT+="$NL"
		fi
		STDOUT+=$(eval "cat <<-EOF | column -Lts ${STDOUT_COLUMN_SEP@Q}
		$_TEMPLATE
		EOF
		")
	done

	echo "$STDOUT"
}
