@echo off
rem is.bat: log TAP comparison
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPisVer=is.bat 0.3;
if '%1'=='%2' goto yup
call "%~dp0/fail" "%~3, got %1"
goto EOF
:yup
call "%~dp0/pass" %3
:EOF
