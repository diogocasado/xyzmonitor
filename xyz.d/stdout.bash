
stdout_init () {
	STDOUT_COLUMN_SEP="|"
	STDOUT_TEMPLATE_FILE=
	STDOUT_TEMPLATE=()

	xyzcfg STDOUT_COLUMN_SEP "Column separator for table format"
	xyzcfg STDOUT_TEMPLATE_FILE "Standard output template file to read from"
	xyzcfg STDOUT_TEMPLATE "Standard output template"
}

stdout_pre () {

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

stdout_write () {
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
