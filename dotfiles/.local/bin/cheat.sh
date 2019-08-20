#!/data/data/com.termux/files/usr/bin/sh
##
##  Search for console tips and tricks via https://cheat.sh service.
##  Dependencies: dash, curl.
##

if [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
	echo
	echo " Usage: cheat.sh [-h|--help] [topic]"
	echo
	echo " Display console tips and tricks for given topic."
	echo " Uses https://cheat.sh service."
	echo
	exit 0
fi

exec curl -H "Accept-language: en" -s "http://cheat.sh/${1}"
