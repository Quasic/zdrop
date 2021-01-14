@echo off
rem startTests.bat: start TAP log
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
echo # %TAPstartTestsVer%; %TAPpassVer% %TAPfailVer% %TAPskipVer% %TAPtodoVer% %TAPwasokVer% %TAPisVer% %TAPisntVer% %TAPpathexistVer% endTests.bat 0.3a
if '%TAPfailed%'=='0' goto allpassed
echo #Failed %TAPfailed% tests
:allpassed
if '%TAPnum%'=='?' goto unk
if '%TAPnum%'=='%TAPrun%' goto numright
echo #Planned %TAPnum% tests, but ran %TAPrun% tests
exit 255
:unk
echo 1..%TAPnum%
:numright
exit %TAPfailed%
