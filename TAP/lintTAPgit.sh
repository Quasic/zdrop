#!/bin/bash
# runs checks on the git repository
# based on default git pre-commit hook
# By Quasic
# Report bugs to https://github.com/Quasic/TAP/issues
# Released under Creative Commons Attribution (BY) 4.0 license
Version=0.3
if git rev-parse --verify HEAD >/dev/null 2>&1
then against=HEAD
else
        # Initial commit: diff against an empty tree object
	if ! against=$(git hash-object -w -t tree /dev/null)
	then
		#shellcheck source=TAP/TAP.bash
		source "$(dirname "${BASH_SOURCE[0]}")/TAP.bash" "$(basename "$0")" 'cwd not in a git repo'
		endtests
	fi
fi
#shellcheck source=TAP/TAP.bash
source "$(dirname "${BASH_SOURCE[0]}")/TAP.bash" "$(basename "${BASH_SOURCE[0]}") $Version" 5
[ "$(git config --bool hooks.allownonascii)" == 'true' ]&&skip 'hooks.allownonascii is true' 2
is "$(git diff --name-only --cached --diff-filter=A -z "$against" | LC_ALL=C tr -d '[ -~]\0' | wc -c)" 0 'staged ASCII filenames'
is "$(git diff --name-only --diff-filter=A -z "$against" | LC_ALL=C tr -d '[ -~]\0' | wc -c)" 0 'ASCII filenames'
okrun "git diff-index --check --cached $against --" 'staged whitespace'
okrun "git diff-index --check $against --" 'whitespace'
okrun 'git fsck --full --cache --strict' 'fsck'
#how-to-test?||skip 'no commit-graph' 1
#okrun 'git commit-graph verify' 'commit-graph verify'
endtests
