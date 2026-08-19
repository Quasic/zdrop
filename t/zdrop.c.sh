#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")/.."||exit 1
verFind(){
	local v="$1"
	shift
	sed -nE 's/^#define '"$v"'VERSION[[:space:]]+"([^"]+)".*/\1/p' "$@"
}
source TAP/TAP.bash zdrop.c 40
t=$(gcc -print-file-name=libz.a);wasok 'Looking for zlib'||
diag "Searched $(gcc -print-search-dirs)"
isnt "$t" 'libz.a' 'zlib installed'
okname 'libz.a exists' [ -f "$t" ]
zlibver=$(gcc -x c - -E -dM <<<'#include <zlib.h>
ZLIB_VERSION'| verFind ZLIB_)
wasok "zlib.h exists, version $zlibver"
okname preprocess gcc -E zdrop.c -o /dev/null
okname compile gcc -S zdrop.c -o /dev/null
okname assemble gcc -c zdrop.c -o /dev/null
gccp=(-fexpensive-optimizations -O3)
while [ "${1:0:1}" == - ]
do
	gccp=("${gccp[@]}" "$1")
	shift
done
okname link-control-test-gcc gcc -pipe -pass-exit-codes "${gccp[@]}" -x c - -o t.exe <<<'int main(void){return 0;}'
okrun file t.exe
okrun rm t.exe
okname link gcc -pipe -pass-exit-codes "${gccp[@]}" zdrop.c "$t" -o t.exe
diag 'gcc version'
gcc -dumpversion|diag
diag 'compiling for'
gcc -dumpmachine|diag
okrun '[ -f t.exe ]' 't.exe produced'
okrun 'chmod +x t.exe' 'chmod'
t=$(./t.exe 2>&1);
is "$?" 10 testrun
testfile=$'Testing 1,2,3...\n\x9f\n\nno EOL@EOF'
#shellcheck disable=SC2016
okrun 'printf "%s" "$testfile">t.txt' 'create testfile t.txt'
is "$(<t.txt)" "$testfile" 'verify testfile'
okrun './t.exe t.txt' compress
okrun '[ -f t.txt.zlib ]' compressed
okrun 'rm t.txt' 'delete testfile'
okrun './t.exe t.txt.zlib' uncompress
okrun '[ -f t.txt ]' uncompressed
is "$(<t.txt)" "$testfile" 'verify cycle'
okrun 'rm t.txt' 'rm uncompressed testfile'
okrun 'rm t.txt.zlib' 'rm compressed testfile'
okrun './t.exe t.exe' self-compress
okrun '[ -f t.exe.zlib ]' self-compressed
okrun 'mv t.exe.zlib t.s.zlib' 'change uncompressed filename'
okrun './t.exe t.s.zlib' self-uncompress
okrun '[ -f t.s ]' self-uncompressed
if command -v git>/dev/null
then
	df='git diff --no-index --'
	pass 'found git diff'
elif command -v diff>/dev/null
then
	df='diff'
	pass 'found diff'
else
	df='printf "no way to diff %s %s" '
	fail 'Please install git or diff'
fi
okrun "cmp t.exe t.s" self-diff
okrun 'rm t.s.zlib' 'rm self-compressed binary'
okrun 'rm t.s' 'rm self-uncompressed binary'
okname 'compress source' ./t.exe zdrop.c
okname 'rename compressed source' mv zdrop.c.zlib s.c.zlib
okname 'uncompress source' ./t.exe s.c.zlib
okrun "$df zdrop.c s.c" 'compare sources'
okname 'rm compressed source' rm s.c.zlib
okname 'rm uncompressed source' rm s.c
if [ "$1" = bin ]
then
	binf="zdrop$(verFind '' zdrop.c)-zlib$zlibver-$(uname -m).exe"
	okrun "mkdir -p bin&&mv t.exe bin/$binf" "Saving to bin/$binf"
else okrun 'rm t.exe' 'rm test binary'
fi
endtests
