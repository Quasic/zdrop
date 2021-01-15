#!/bin/bash
# updates TAP library and redirects to TAP/testcases.bash
# By Quasic
# Report bugs to https://github.com/Quasic/zdrop/issues
# Released under Creative Commons Attribution (BY) 4.0 license
printf '%s\n' "${BASH_SOURCE[0]} 0.1"
if cd "$(dirname "${BASH_SOURCE[0]}")"&&[ -d TAP ]
then
	#shellcheck disable=SC1091
	[ -f ../TAP/TAP/updateTAP.bsh ]&&
		source ../TAP/TAP/updateTAP.bsh
	source TAP/testcases.bash zdrop "$@"
else
	printf 'Could not find TAP folder...\n'
	[[ "$-" = *i* ]]&&read -rn1 -p 'Press a key to exit 1'
	exit 1
fi
printf '\n'
