@echo off
rem bailout.bat: bail out of a TAP test series
rem by Quasic
rem Report bugs to https://github.com/Quasic/TAP/issues
rem Released under Creative Commons Attribution (BY) 4.0 license
echo # %TAPstartTestsVer%; %TAPpassVer% %TAPfailVer% %TAPskipVer% %TAPtodoVer% %TAPwasokVer% %TAPisVer% %TAPisntVer% bailout.bat 0.2
echo Bail out!  %1
exit 255
