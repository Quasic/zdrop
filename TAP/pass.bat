@echo off
rem pass.bat: log TAP pass
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPpassVer=pass.bat 0.3;
set /A TAPrun=TAPrun+1
if '%TAPskip%'=='0' goto noskip
set /A TAPskip=TAPskip-1
echo ok %TAPrun% - %1 # %TAPskiptype% %TAPskipwhy%
goto EOF
:noskip
echo ok - %1
:EOF
