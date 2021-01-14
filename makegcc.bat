cd %~dp0
for /f "tokens=*" %%i in ('gcc -print-file-name^=libz.a') do set libzpath=%%i
if errorlevel 1 goto end
mkdir bin
gcc zdrop.c "%libzpath%" -o bin/zdrop.exe -fexpensive-optimizations -O3 -pipe -pass-exit-codes
explorer bin
:end
