@echo off
rem wasok.bat: log errorlevel in TAP
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
set TAPwasokVer=wasok.bat 0.3;
if errorlevel 1 goto fail
call "%~dp0/pass" %1
goto EOF
:fail
call "%~dp0/fail" "%~1, code %errorlevel%"
:EOF
