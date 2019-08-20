if [ "${SHLVL}" = 1 ]; then
	# Erase console screen on logout.
	echo -ne "\\e[3J"
	clear
fi
