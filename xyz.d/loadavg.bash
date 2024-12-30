
loadavg_init () {
	xyzenv LOADAVG_1 "Load avg 1min"
	xyzenv LOADAVG_5 "Load avg 5min"
	xyzenv LOADAVG_15 "Load avg 15min"
	xyzenv LOADAVG_1_5_15 "Load avg 1/5/15min"
}

loadavg_set () {
	local _OUT=$(cat /proc/loadavg)
	LOADAVG_1=$(echo "$_OUT" | cut -d" " -f1)
        LOADAVG_5=$(echo "$_OUT" |  cut -d" " -f2)
        LOADAVG_15=$(echo "$_OUT" |  cut -d" " -f3)
        LOADAVG_1_5_15="$LOADAVG_1 $LOADAVG_5 $LOADAVG_15"
}
        
