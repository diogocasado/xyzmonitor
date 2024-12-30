
users_init () {

        xyzenv USERS_LOGINS_NAMES "User names currently logged in"
        xyzenv USERS_LOGINS_IPS "Ips of users currently logged in"
	xyzfun USERS_LOGINS_LIST "Formated output list of: * USERS_LOGINS_NAMES|USERS_LOGINS_IPS"
}

users_set () {

	USERS_LOGINS_NAMES=()
	USERS_LOGINS_IPS=()

	local _LOGINS=$(who | awk '{printf "%s ", $1} END {print ""}')
	local _USER
	for _USER in $_LOGINS; do
		USERS_LOGINS_NAMES+=("$_USER")
	done

	local _IPS=$(who | awk '{gsub("[()]", "", $0); printf "%s ", $6} END {print ""}')
	local _IP
	for _IP in $_IPS; do
		USERS_LOGINS_IPS+=("$_IP")
	done
}

USERS_LOGINS_LIST () {
	for (( i=0; i<${#USERS_LOGINS_NAMES[@]}; i++ )); do
		echo "* ${USERS_LOGINS_NAMES[$i]}|${USERS_LOGINS_IPS[$i]}"
	done
}

