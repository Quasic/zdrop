@echo off
rem startTests.bat: start TAP log
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPstartTestsVer=startTests.bat 0.3
set TAPrun=0
set TAPfailed=0
set TAPskip=0
echo #TAP testing %1 (%TAPstartTestsVer%)
if '%2'=='?' goto unk
if 1%2 EQU +1%2 goto num
echo 1..0 # Skipped: %2
set TAPnum=0
goto endif
:unk
set TAPnum=?
goto endif
:num
echo 1..%2
set TAPnum=%2
:endif
