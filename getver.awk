# This file parses version information
# Please report bugs at https://github.com/quasic/zdrop/issues
# Released under Creative Commons Attribution (BY) 4.0 license
/^#define VERSION "[0-9.a-z]+"\r?$/{
	sub(/^[^"]*"/,"")
	sub(/"\r?$/,"")
	print
	if(verStr)print"zdrop "$0"; "verStr"; getver.awk 1.0">"/dev/stderr"
	exit
}
