
mnt_init () {
	MNT_PATHS=()

	xyzcfg MNT_PATHS "Mount point paths"
	xyzenv MNT_SIZE "Sizes for each mount point"
	xyzenv MNT_USED "Used space for each mount point"
	xyzenv MNT_AVAIL "Available space for each mount point"
	xyzenv MNT_USE "Percent used space for each mount point"
	xyzfun MNT_LIST "Formated output list of: * MNT_PATHS|MNT_USE (MNT_USED)|MNT_AVAIL|MNT_SIZE"
}

mnt_set () {
	local _DF_OUT="$(df -h)"

	MNT_SIZE=()
	MNT_USED=()
	MNT_AVAIL=()
	MNT_USE=()

	local _PATH
	for _PATH in ${MNT_PATHS[@]}; do
		local _DF_PATH="$(echo "$_DF_OUT" | grep "$_PATH$")"
		if [[ -n ${_DF_PATH:+x} ]]; then
			$(echo "$_DF_PATH" | awk '{print "local _SIZE=" $2 " _USED=" $3 " _AVAIL=" $4 " _USE=" $5}')
			MNT_SIZE+=("$_SIZE")
			MNT_USED+=("$_USED")
			MNT_AVAIL+=("$_AVAIL")
			MNT_USE+=("$_USE")
		else
			MNT_SIZE+=($NULL)
			MNT_USED+=($NULL)
			MNT_AVAIL+=($NULL)
			MNT_USE+=($NULL)
		fi
	done
}

MNT_LIST () {
        for (( i=0; i<${#USERS_LOGINS_NAMES[@]}; i++ )); do
                echo "* ${MNT_PATHS[$i]}|${MNT_USE[$i]} (${MNT_USED[$i]})|${MNT_AVAIL[$i]}|${MNT_SIZE[$i]}"
        done
}
