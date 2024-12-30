
gchat_init () {
	GCHAT_CREDENTIALS_FILE=
	GCHAT_SPACE_ID=
	GCHAT_MESSAGE_ID=
	GCHAT_TEMPLATE=

	xyzcfg GCHAT_CREDENTIALS_FILE "Google service credentials json file (absolute path)"
	xyzcfg GCHAT_SPACE_ID "Google Chat space id, don't forget to add the app to the space"
	xyzcfg GCHAT_MESSAGE_ID "Google Chat message id to update, will be provided on first run"
	xyzcfg GCHAT_TEMPLATE "Google Chat message template. Defaults to STDOUT_TEMPLATE"
}

gchat_post () {
	if [[ -z "$GCHAT_CREDENTIALS_FILE" || -z "$GCHAT_SPACE_ID" ]]; then
		return
	fi

	local _NOW=$(date -u +%s)

	local _TOKEN_FILE=$(basenc --base64url <<< $GCHAT_CREDENTIALS_FILE | tr -d '=')
	local _TOKEN_FILE="/tmp/token${_TOKEN_FILE:1:6}.json"
	local _TOKEN_CREATED=$(stat -c %W $_TOKEN_FILE 2> /dev/null)
	local _TOKEN_ELAPSED=$((_NOW - _TOKEN_CREATED))

	if [[ ! -f $_TOKEN_FILE ]] || [[ $_TOKEN_ELAPSED -ge 1800 ]]; then
		rm -f $_TOKEN_FILE
		gchat_oauth2 "$_TOKEN_FILE"
	fi

	local _TOKEN_DATA="$(cat $_TOKEN_FILE)"
	local _TOKEN=$(gchat_json_property "access_token" "$_TOKEN_DATA")
	
	if [[ -z "$_TOKEN" ]]; then
		error "Invalid token. $_TOKEN_FILE"
	fi

	local _CBLK=$'```'

	local _TEMPLATE=$GCHAT_TEMPLATE
	if [[ -z "$_TEMPLATE" ]]; then
		_TEMPLATE="$STDOUT_TEMPLATE"
	fi

	local _CONTENT=$(escape "$STDOUT")

	local _URL="https://chat.googleapis.com/v1/spaces/$GCHAT_SPACE_ID/messages"
	local _METHOD="POST"
	if [[ ! -z "$GCHAT_MESSAGE_ID" ]]; then
		_URL+="/$GCHAT_MESSAGE_ID?updateMask=text"
		_METHOD="PATCH"
	fi

	debug "$_METHOD $_URL"
	local _RESPONSE=$(curl -s -X $_METHOD -H "Content-Type: application/json; charset=UTF-8" -H "Authorization: Bearer $_TOKEN" -d@- "$_URL" <<-EOF
	{
	  "text": "$_CBLK$_CONTENT$_CBLK"
	}
	EOF
	)
	debug "$_RESPONSE"

	if [[ -z "$GCHAT_MESSAGE_ID" ]]; then
		local _NAME=$(gchat_json_property "name" "$_RESPONSE")
		local _ID_EXPR='spaces/[^/]+/messages/(.*)'
		if [[ "$_NAME" =~ $_ID_EXPR ]]; then
			local _MESSAGE_ID="${BASH_REMATCH[1]}"
			>&2 echo "---"
			>&2 echo "Please add the following to your configuration files"
			>&2 echo "to update the message being posted on google chat:"
			>&2 echo "GCHAT_MESSAGE_ID=$_MESSAGE_ID"
		fi
	fi
}

gchat_json_property () {
	set -e
	local _PROPERTY=$1
	local _EXPR='"'$_PROPERTY'"[ ]*:[ ]*"([^"]*)",?'
	if [[ "$2" =~ $_EXPR ]]; then
	        echo "${BASH_REMATCH[1]}"
		return
	fi
	error "Missing property $_PROPERTY"
	exit 1
}

gchat_oauth2 () {
	local _TOKEN_FILE="$1"

	debug "Requesting oauth2 token"

	if [[ ! -f $GCHAT_CREDENTIALS_FILE ]]; then
		error "Credentials file not found. $GCHAT_CREDENTIALS_FILE"
	fi	

	local _CREDENTIALS_DATA="$(cat $GCHAT_CREDENTIALS_FILE)"
	local _KEY_ID=$(gchat_json_property "private_key_id" "$_CREDENTIALS_DATA")
	local _PRIV_KEY=$(gchat_json_property "private_key" "$_CREDENTIALS_DATA")
	local _ISS=$(gchat_json_property "client_email" "$_CREDENTIALS_DATA")
	local _SCOPE="https://www.googleapis.com/auth/chat.bot"
	local _AUD="https://oauth2.googleapis.com/token"
	local _IAT=$(date -u +%s)
	local _EXP=$(date -u +%s -d '+30 min')

	if [[ -z "$_KEY_ID" ]] || [[ -z "$_PRIV_KEY" ]] || [[ -z "$_ISS" ]]; then
		error "Invalid credentials file."
	fi
	
	local _PRIV_KEY_FILE=$(mktemp /tmp/privXXXXX.pem)
	local _SIGN_FILE=$(mktemp /tmp/signXXXXX.sha256)

	printf '%b' "$_PRIV_KEY" > $_PRIV_KEY_FILE

	_JWT_HEADER='{"alg":"RS256","typ":"JWT","kid":"'$_KEY_ID'"}'
	_JWT_HEADER_BASE64=$(basenc --base64url -w0 <<< "$_JWT_HEADER" | tr -d '=')

	_JWT_CLAIMS='{"iss":"'$_ISS'","scope":"'$_SCOPE'","aud":"'$_AUD'","iat":'$_IAT',"exp":'$_EXP'}'
	_JWT_CLAIMS_BASE64=$(basenc --base64url -w0 <<< "$_JWT_CLAIMS" | tr -d '=')

	_JWT=${_JWT_HEADER_BASE64}.${_JWT_CLAIMS_BASE64}
	echo -n "$_JWT" | openssl dgst -sha256 -sign $_PRIV_KEY_FILE -out $_SIGN_FILE
	_JWT+=.$(basenc --base64url -w0 $_SIGN_FILE | tr -d '=')

	rm -f $_PRIV_KEY_FILE
	rm -f $_SIGN_FILE

	curl -s -X POST "https://oauth2.googleapis.com/token" --data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" --data-urlencode "assertion=$_JWT" > $_TOKEN_FILE
}
