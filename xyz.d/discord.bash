
discord_init () {
	DISCORD_ID=
	DISCORD_TOKEN=
	DISCORD_MESSAGE_ID=
	DISCORD_TEMPLATE=

	xyzcfg DISCORD_ID "Discord webhook id"
	xyzcfg DISCORD_TOKEN "Discord webhook token"
	xyzcfg DISCORD_MESSAGE_ID "Discord message id to update"
	xyzcfg DISCORD_TEMPLATE "Discord message template. Defaults to STDOUT_TEMPLATE"
}

discord_post () {
	if [[ -z "$DISCORD_ID" || -z "$DISCORD_TOKEN" ]]; then
		return
	fi

	local _CBLK=$'```'

	local _TEMPLATE=$DISCORD_TEMPLATE
	if [[ -z "$_TEMPLATE" ]]; then
		_TEMPLATE="$STDOUT_TEMPLATE"
	fi

	local _CONTENT=$(escape "$STDOUT")

	local _URL="https://discord.com/api/webhooks/$DISCORD_ID/$DISCORD_TOKEN"
	local _METHOD="POST"
	if [[ ! -z "$DISCORD_MESSAGE_ID" ]]; then
		_URL+="/messages/$DISCORD_MESSAGE_ID"
		_METHOD="PATCH"
	fi
	_URL+="?wait=1"

	debug "$_METHOD $_URL"
	local _RESPONSE=$(curl -s -X $_METHOD -H "Content-Type: application/json; charset=UTF-8" -d@- "$_URL" <<-EOF
	{
	  "content": "$_CBLK$_CONTENT$_CBLK"
	}
	EOF
	)
	debug "$_RESPONSE"

	if [[ -z "$DISCORD_MESSAGE_ID" ]]; then
		# I know this is naive aproach to json parsing, but life is too short
		local _EXPR='"id"[ ]*:[ ]*"([^"]*)",?'
		if [[ "$_RESPONSE" =~ $_EXPR ]]; then
			>&2 echo "---"
			>&2 echo "Please add the following to your configuration files"
			>&2 echo "to update the message being posted on discord:"
			>&2 echo "DISCORD_MESSAGE_ID=${BASH_REMATCH[1]}"
		fi
	fi
}

