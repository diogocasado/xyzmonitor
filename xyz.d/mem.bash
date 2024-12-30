
mem_init () {
	xyzenv MEM_TOTAL "Total memory"
	xyzenv MEM_USED "Memory in use"
}

mem_set () {
	local _FREE_OUT=$(free -w)
        MEM_TOTAL=$(echo "$_FREE_OUT" | grep "Mem" | awk '{printf "%.1fGB", $2/1024/1000}')
        MEM_USED=$(echo "$_FREE_OUT" | grep "Mem" | awk '{printf "%.1f%%", ($2-$8)/$2*100}')
}

