@echo off
rem pathexist.bat: log TAP path check
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPpathexistVer=pathexist.bat 0.1;
if exist "%1" goto yup
call "%~dp0/fail" %2
goto EOF
:yup
call "%~dp0/pass" %2
:EOF
