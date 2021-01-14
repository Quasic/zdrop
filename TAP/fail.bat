@echo off
rem fail.bat: log TAP fail
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPfailVer=fail.bat 0.3;
set /A TAPrun=TAPrun+1
if '%TAPskip%'=='0' goto noskip
set /A TAPskip=TAPskip-1
if '%TAPskiptype%'=='skip' goto skip
echo not ok %TAPrun% - %1 # %TAPskiptype% %TAPskipwhy%
if not '%TAPskiptype%'=='TODO' goto EOF
echo #   Failed (TODO) test %1
goto EOF
:skip
echo ok %TAPrun% - %1 # skip %TAPskipwhy%
goto EOF
:noskip
echo not ok - %1
:EOF
