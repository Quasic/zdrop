#!/bin/bash
# updates TAP library and redirects to TAP/testcases.bash
# By Quasic
# Report bugs to https://github.com/Quasic/zdrop/issues
# Released under Creative Commons Attribution (BY) 4.0 license
printf '%s\n' "${BASH_SOURCE[0]} 0.1"
if cd "$(dirname "${BASH_SOURCE[0]}")/TAP"
then
	#shellcheck source=../TAP/TAP/updateTAP.bsh
	[ -f ../../TAP/TAP/updateTAP.bsh ]&&source ../../TAP/TAP/updateTAP.bsh
	#shellcheck source=TAP/testcases.bash
	source testcases.bash zdrop "$@"
else
	[[ "$-" = *i* ]]&&read -rn1 -p 'Press a key to exit 1'
	exit 1
fi
