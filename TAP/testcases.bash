#!/bin/bash
Version=0.1b
if [ "$1" = --help ]||[ "$1" = -h ]||[ "$2" = --help ]||[ "$2" = -h ]
then printf '%s
sets up prove to run TAP testcases
Usage: bash [-i] TAP/testcases.sh RepoName [arguments]
-i        enables the interactive menu
RepoName  is the name to display in the log
arguments options and tests as passed to prove (See prove --help)

by Quasic [https://quasic.github.io]
Released under Creative Commons Attribution (BY) 4.0 license
Report bugs to https://github.com/Quasic/TAP/issues
' "${BASH_SOURCE[0]} $Version"
	exit
fi
useRC=1
shopt -s nullglob
declare -a o
declare -a t
menu(){
	local -a a
	case "${1^}" in
	'') true;;
	-) t[${#t[@]}]=--state=failed;;
	+) t[${#t[@]}]=--state=passed;;
	'*') t[${#t[@]}]=--state=slow;;
	F) t[${#t[@]}]=--state=fresh;;
	L) t[${#t[@]}]=--state=last;;
	P) o[${#o[@]}]=-p;;
	S) o[${#o[@]}]=--shuffle;;
	Q) exit;;
	'.') o[${#o[@]}]=--state=save;;
	',') useRC=$((1-useRC))
		if [ "$useRC" != 1 ]
		then printf 'Not using .proverc\n'
		elif [ -f .proverc ]
		then printf 'Using .proverc:\n%s\n' "$(<.proverc)"
		else printf 'No .proverc found to use\n'
		fi;;
	'/') for f in TAP/lintTAP*
		do t[${#t[@]}]="$f"
		done;;
	'#') a=()
		[ "$useRC" = 1 ]||a[0]=--norc
		[ "${#t[@]}" = 0 ]&&a[${#a[@]}]=--state=slow
		prove --dry "${o[@]}" "${a[@]}" "${t[@]}";;
	'!') a=()
		[ "$useRC" = 1 ]||a[0]=--norc
		[ "${#t[@]}" = 0 ]&&a[${#a[@]}]=--state=slow
		prove "${o[@]}" "${a[@]}" "${t[@]}"
		printf 'Returned code %i\n' $?;;
	'%') o=();;
	'_') t=();;
	*) printf 'Unknown command: %s\n' "$1"
	esac
	a=()
	[ "$useRC" = 1 ]||a[0]=--norc
	if [ "${#t[@]}" = 0 ]
	then
		a[${#a[@]}]=--state=slow
		printf 'No tests, default is saved tests, slowest first\n'
	fi
	printf 'prove %s\n' "${o[*]} ${a[*]} ${t[*]}"
	printf 'Menu: Enter or space to run this command and exit
Q quit without running any tests
# show which tests would run, without running them, yet
! run tests and return to this menu
%% clear options except --norc (,) and --state=[test group]
_ clear tests
. save test info to .prove
/ add TAP/lintTAP*
'
	[ -f .prove ]&&printf 'L run tests ran at last save
- run tests that failed last save (save again to eliminate new passes)
+ run tests that passed last save (check for new errors)
F run any tests modified since last save
* run all tests in fastest to slowest order
P show all errors (-p option)
'
	[ ${#t[@]} -gt 1 ]&&printf 'S to shuffle\n'
	printf ', '
	[ "$useRC" = 1 ]&&printf 'do not '
	printf 'use .proverc\n'
}
printf '\e]0;%s testcases\e\\%s testcases (%s):\n' "$1" "$1" "${BASH_SOURCE[0]} $Version"
shift
if cd "$(dirname "${BASH_SOURCE[0]}")/.."
then
	if [ -f /sys/devices/system/cpu/present ]
	then
		printf 'Reading /sys/devices/system/cpu/present...'
		cpus=$(</sys/devices/system/cpu/present)
		cpus="${cpus:2}"
	elif [ -f /proc/stat ]
	then
		printf 'Reading /proc/stat...'
		cpus=-1
		while true
		do
			read -r f
			[ "${f:0:3}" = cpu ]||break
			((cpus++))
		done</proc/stat
	else cpus=1
	fi
	printf 'Found %i CPUs\n' "$cpus"
	o=( --trap "--jobs=$((cpus+1))" )
	if [ -d TAP/Parser/SourceHandler ]
	then
		for f in TAP/Parser/SourceHandler/*.pm
		do [[ "$f" =~ ^TAP/Parser/SourceHandler/(.*)\.pm$ ]]&&o[${#o[@]}]="--source=${BASH_REMATCH[1]}"
		done
		PERL5LIB="$(realpath .;[ "$PERL5LIB" = '' ]||perl -V:path_sep)$PERL5LIB"
	fi
	for f
	do
		if [ "${f:0:1}" = - ]
		then
			if [ "$f" = --norc ]
			then useRC=0
			elif [ "${f:0:8}" = --state= ]&&[ "$f" != --state=save ]
			then t[${#t[@]}]="$f"
			else o[${#o[@]}]="$f"
			fi
		elif [ "${f:0:7}" = lintTAP ]&&[ -f "TAP/$f" ]
		then t[${#t[@]}]="TAP/$f"
		else
			n=${#t[@]}
			for q in t/"$f".* "t/$f" "t/testcases$f"
			do [ -f "$q" ]&&t[${#t[@]}]="$q"
			done
			[ "$n" = ${#t[@]} ]&&printf 'No test was found for %s\n' "$f"
		fi
	done
	for q in t/testcases.*
	do [ -f "$q" ]&&t[${#t[@]}]="$q"
	done
	printf 'PERL5LIB=%s\n' "$PERL5LIB"
	[ -f .proverc ]&&printf '.proverc:\n%s\n' "$(<.proverc)"
	if [[ "$-" = *i* ]]
	then
		menu
		for f in 6 5 4 3 2 1 0
		do read -rn1 -t1 -p $'\r'"Please reply in the next $f seconds" q&&break
		done
		printf '\n'
		while [ "$q" != '' ]&&[ "$q" != ' ' ]
		do
			menu "$q"
			read -rn1 q
			printf '\n'
		done
	fi
	[ "$useRC" = 1 ]||o[${#o[@]}]=--norc
	#shellcheck disable=SC2191
	[ "${#t[@]}" = 0 ]&&t=(--state=slow)
	printf 'prove %s\n' "${o[*]} ${t[*]}"
	prove "${o[@]}" "${t[@]}"
	r=$?
	if [ $r = 0 ]
	then printf '\e]0;[Passed] %s testcases\e\\Passed testcases\n' "$TESTING"
	else printf '\e]0;[Failed] %s testcases\e\\Failed testcases\n' "$TESTING"
	fi
else
	r=1
	printf '\e]0;[Failed to start] %s testcases\e\\Failed to chdir!\n' "$TESTING"
fi
[[ "$-" =~ 'i' ]]&&read -rn1 -p 'Press a key to close log...'
exit $r
