
fs_init () {
	FS_PATHS=("/var/log")

	xyzcfg FS_PATHS "Mount point paths"
	xyzenv FS_SIZE "Sizes for each fs path"
	xyzfun FS_LIST "Formatted output list of: * FS_PATHS|FS_SIZE"
}

fs_set () {

	FS_SIZE=()

	local _PATH
	for _PATH in ${FS_PATHS[@]}; do

		if [[ -e "$_PATH" ]]; then
			$(du -h "$_PATH" | grep "$_PATH$" | awk '{print "local _SIZE=" $1}')
			FS_SIZE+=("$_SIZE")
		else
			FS_SIZE+=($NULL);
		fi
	done
}

FS_LIST () {
        for (( i=0; i<${#FS_PATHS[@]}; i++ )); do
                echo "* ${FS_PATHS[$i]}|${FS_SIZE[$i]}"
        done
}
