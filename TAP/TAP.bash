#!/bin/bash
#TAP format testcase library for bash
#by Quasic
#released under Creative Commons Attribution (BY) 4.0 license
#Please report bugs at https://github.com/Quasic/TAP/issues

printf '#TAP testing %s (TAP.bash 1.0e)\n' "$1"
case "$2" in
'?') TAP_NumTests='?';;
*[!0-9]*|'') printf '1..0 #Skipped: %s\n' "$2";TAP_NumTests=0;;
*) printf '1..%i\n' "$2";TAP_NumTests=$2;;
esac
TAP_TestsRun=0
TAP_TestsFailed=0
TAP_SkipTests=0
endtests(){
	if [ "$TAP_TestsFailed" -ne 0 ]
	then
		printf '#Failed %i tests\n' "$TAP_TestsFailed"
		[ "$TAP_TestsFailed" -gt 254 ]&&TAP_TestsFailed=254
	fi
	if [ "$TAP_NumTests" = '?' ]
	then printf '1..%i\n' "$TAP_TestsRun"
	elif [ "$TAP_TestsRun" -ne "$TAP_NumTests" ]
	then
		printf '#Planned %i tests, but ran %i tests\n' "$TAP_NumTests" "$TAP_TestsRun"
		TAP_TestsFailed=255
	fi
	[ "$TAP_subtest" != 1 ]&&[[ $- == *i* ]]&&read -rn1 -p "Press a key to close log (will return $TAP_TestsFailed)">&2
	exit $TAP_TestsFailed
}
bailout(){
	printf '\nBail out!  %s\n' "$1"
	exit 255
}
pass(){
	((TAP_TestsRun++))
	if [ "$TAP_SkipTests" -gt 0 ]
	then
		((TAP_SkipTests--))
		printf 'ok %i - %s # %s\n' "$TAP_TestsRun" "$1" "$TAP_SkipType $TAP_SkipReason"
	else printf 'ok - %s\n' "$1"
	fi
	return 0
}
fail(){
	((TAP_TestsRun++))
	if [ "$TAP_SkipTests" -gt 0 ]
	then
		((TAP_SkipTests--))
		if [ "$TAP_SkipType" = skip ]
		then printf 'ok %i - %s # skip %s\n' "$TAP_TestsRun" "$1" "$TAP_SkipReason"
		else
			printf 'not ok %i - %s # %s\n' "$TAP_TestsRun" "$1" "$TAP_SkipType $TAP_SkipReason"
			[ "$TAP_SkipType" = TODO ]&&printf '#   Failed (TODO) test "%s"\n' "$1"
		fi
	else
		((TAP_TestsFailed++))
		printf 'not ok - %s\n' "$1"
	fi
	return 1
}
skip(){
	if [ "$TAP_SkipTests" -gt 0 ]
	then
		diag "skip called during $TAP_SkipType, nesting unsupported"
	fi
	TAP_SkipReason=$1
	TAP_SkipTests=$2
	TAP_SkipType='skip'
}
todo(){
	if [ "$TAP_SkipTests" -gt 0 ]
	then
		diag "todo called during $TAP_SkipType, nesting unsupported"
	fi
	TAP_SkipReason=$1
	TAP_SkipTests=$2
	TAP_SkipType='TODO'
}
diag(){
	if [ $# -eq 0 ]
	then
		local r
		while read -r r
		do printf '#%s\n' "$r"
		done
	elif [ "$1" != '' ]
	then diag<<<"$1"
	fi
}
subtest(){	#name, num, function/code; auto endTests
	[ "$TAP_SkipTests" -gt 0 ]&&[ "$TAP_SkipType" = skip ]&&pass "$1"&&return
	printf '#TAP subtesting %s\n' "$1"
	case "$2" in
	'?') true;;
	*[!0-9]*|'')
		printf '    1..0 #Skipped: %s\n' "$2"
		pass "$1 # Skip $2"
		return 0
	esac
	(
		if [ "$2" = '?' ]
		then TAP_NumTests='?'
		else
			printf '1..%i\n' "$2"
			TAP_NumTests=$2
		fi
		#shellcheck disable=SC2030
		TAP_TestsRun=0
		#shellcheck disable=SC2030
		TAP_TestsFailed=0
		#shellcheck disable=SC2030
		TAP_SkipTests=0
		TAP_subtest=1
		trap endtests EXIT
		if [ $# -eq 3 ]
		then eval "$3"
		else shift 2;"$@"
		fi
	)|gawk '/^[ \t]Bail out!  /{bailed=1}{print"    "$0}END{if(bailed)exit 255}'
	local -a m=("${PIPESTATUS[@]}")
	if [ "${m[0]}" = 0 ]
	then pass "$1"
	else fail "$1, code ${m[0]}"
	fi
	case "${m[1]}" in
	0) true;;
	1) printf '#Subtest gawk parser error';;
	2) printf '#Subtest fatal gawk parser error';;
	127) bailout 'gawk not found';;
	255) bailout "subtest bailed out";;
	*) printf '#Subtest parser returned unknown exit status %i\n' "${m[1]}"
	esac
	return "${m[0]}"
}
wasok(){
	local r=$?
	if [ "$r" -eq 0 ]
	then pass "$1"
	else fail "$1, code $r"
	fi
}
okrun(){
	#shellcheck disable=SC2031
	[ "$TAP_SkipTests" -gt 0 ]&&[ "$TAP_SkipType" = skip ]&&pass "$2"&&return
	local r
	if r=$(eval "$1")
	then pass "$2"
	else
		fail "$2 ($1) code $?"
		diag "$r"
		return 1
	fi
}
okname(){
	#shellcheck disable=SC2031
	[ "$TAP_SkipTests" -gt 0 ]&&[ "$TAP_SkipType" = skip ]&&pass "$1"&&return
	local r
	local n
	n=$1
	shift
	if r=$("$@")
	then pass "$n"
	else
		fail "$n {$*} code $?"
		diag "$r"
		return 1
	fi
}
is(){
	if [ "$1" = "$2" ]
	then pass "$3"
	else fail "$3, got $1"
	fi
}
isnt(){
	if [ "$1" = "$2" ]
	then fail "$3, got $1"
	else pass "$3"
	fi
}
like(){
	if [[ "$1" =~ $2 ]]
	then pass "$3"
	else fail "$3, got $1, which didn't match $2"
	fi
}
unlike(){
	if [[ "$1" =~ $2 ]]
	then IFS=')(' fail "$3, got $1, which matched $2 for (${BASH_REMATCH[*]})"
	else pass "$3"
	fi
}
