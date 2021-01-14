@echo off
rem isnt.bat: log TAP contrast
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPisntVer=isnt.bat 0.3;
if '%1'=='%2' goto f
call "%~dp0/pass" %3
goto EOF
:f
call "%~dp0/fail" "%~3, got %1"
:EOF
