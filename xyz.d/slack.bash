
slack_init () {
	SLACK_TOKEN=
	SLACK_CHANNEL_ID=
	SLACK_MESSAGE_TS=
	SLACK_TEMPLATE=

	xyzcfg SLACK_TOKEN "Slack app token"
	xyzcfg SLACK_CHANNEL_ID "Slack channel id"
	xyzcfg SLACK_MESSAGE_TS "Slack message ts to update"
	xyzcfg SLACK_TEMPLATE "Slack message template. Defaults to STDOUT_TEMPLATE"
}

slack_post () {
	if [[ -z "$SLACK_TOKEN" || -z "$SLACK_CHANNEL_ID" ]]; then
		return
	fi

	local _CBLK=$'```'

	local _TEMPLATE=$SLACK_TEMPLATE
	if [[ -z "$_TEMPLATE" ]]; then
		_TEMPLATE="$STDOUT_TEMPLATE"
	fi

	local _CONTENT=$(escape "$STDOUT")

	local _URL="https://slack.com/api/chat."
	local _METHOD="postMessage"
	local _TS=
	if [[ -n "$SLACK_MESSAGE_TS" ]]; then
		_METHOD="update"
		_TS=",\"ts\": \"$SLACK_MESSAGE_TS\""
	fi
	_URL+="$_METHOD"

	debug "POST $_URL"
	local _RESPONSE=$(curl -s -X POST -H "Content-Type: application/json; charset=UTF-8" -H "Authorization: Bearer $SLACK_TOKEN" -d@- "$_URL" <<-EOF
	{
	  "channel": "$SLACK_CHANNEL_ID",
	  "text": "$_CBLK$_CONTENT$_CBLK"
	  $_TS
	}
	EOF
	)
	debug "$_RESPONSE"

	if [[ -z "$SLACK_MESSAGE_TS" ]]; then
		# I know this is naive aproach to json parsing, but life is too short
		local _EXPR='"ts"[ ]*:[ ]*"([^"]*)",?'
		if [[ "$_RESPONSE" =~ $_EXPR ]]; then
			>&2 echo "---"
			>&2 echo "Please add the following to your configuration files"
			>&2 echo "to update the message being posted on slack:"
			>&2 echo "SLACK_MESSAGE_TS=${BASH_REMATCH[1]}"
		fi
	fi
}

