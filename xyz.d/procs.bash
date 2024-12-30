
procs_init () {
	PROCS_CMDS=()
	PROCS_EUSER_COL=30

	xyzcfg PROCS_CMDS "Command names to filter ps output"
	xyzcfg PROCS_EUSER_COL "EUSER column width to get rid of ellipses"
	xyzenv PROCS_PID "Process id for each command"
	xyzenv PROCS_EUSER "Effective user name for each command"
	xyzenv PROCS_PCPU "CPU usage for each process"
	xyzenv PROCS_PMEM "Memory usage for each command"
	xyzfun PROCS_LIST "Formated output list of: * PROCS_CMDS|PROCS_PCPU|PROCS_PMEM"
}

procs_set () {
	local _PS_OUT="$(ps -Ao pid,euser:${PROCS_EUSER_COL},pcpu,pmem,comm)"

	PROCS_PID=()
	PROCS_EUSER=()
	PROCS_PCPU=()
	PROCS_PMEM=()

	local _CMD
	for _CMD in ${PROCS_CMDS[@]}; do
		_PS_CMD=$(echo "$_PS_OUT" | grep $_CMD)
		if [[ -n ${_PS_CMD:+x} ]]; then
			$(echo "$_PS_CMD" | awk '{print "local _PID=" $1 " _EUSER=" $2 " _PCPU=" $3 " _PMEM=" $4}')
			PROCS_PID+=("$_PID")
			PROCS_EUSER+=("$_EUSER")
			PROCS_PCPU+=("$_PCPU%")
			PROCS_PMEM+=("$_PMEM%")
		else
			PROCS_PID+=($NULL)
			PROCS_EUSER+=($NULL)
			PROCS_PCPU+=($NULL)
			PROCS_PMEM+=($NULL)
		fi
	done
}

PROCS_LIST () {
	for (( i=0; i<${#PROCS_CMDS[@]}; i++ )); do
		echo "* ${PROCS_CMDS[$i]}|${PROCS_PCPU[$i]}|${PROCS_PMEM[i]}"
	done
}
