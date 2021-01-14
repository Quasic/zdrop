@echo off
cd %~dp0\..
call TAP\startTests zdrop.c 34
for /f "tokens=*" %%i in ('gcc -print-file-name^=libz.a') do set libzpath=%%i
call TAP\wasok "Looking for zlib"
echo # libzpath=%libzpath%
call TAP\isnt "%libzpath%" "libz.a" "zlib installed"
call TAP\pathexist "%libzpath%" "libz.a exists"
gcc -E zdrop.c -o NUL
call TAP\wasok preprocess
gcc -S zdrop.c -o t.s
call TAP\wasok compile
gcc -c zdrop.c -o t.o
call TAP\wasok assemble
gcc -pass-exit-codes -pipe -fexpensive-optimizations -O3 zdrop.c "%libzpath%" -o t.exe
call TAP\wasok link
call TAP\pathexist t.exe "t.exe produced"
.\t.exe 2>NUL
call TAP\is "%ERRORLEVEL%" "10" testrun

.\t.exe zdrop.c
call TAP\wasok "compress zdrop.c"
call TAP\pathexist zdrop.c.zlib "compressed zdrop.c"
ren zdrop.c.zlib s.c.zlib
call TAP\wasok "rename zdrop.c.zlib->s.c.zlib"
call TAP\pathexist s.c.zlib "s.c.zlib exists"
.\t.exe s.c.zlib
call TAP\wasok "uncompress source"
call TAP\pathexist s.c "uncompressed source"
fc zdrop.c s.c
call TAP\wasok "source diff"
del s.c.zlib
call TAP\wasok "rm compressed source"
del s.c
call TAP\wasok "rm uncompressed source"

.\t.exe t.s
call TAP\wasok "compress binary"
call TAP\pathexist t.s.zlib self-compressed
ren t.s.zlib s.c.zlib
call TAP\wasok "change uncompressed filename"
call TAP\pathexist s.c.zlib "changed uncompressed filename"
.\t.exe s.c.zlib
call TAP\wasok "uncompress binary"
call TAP\pathexist s.c "uncompressed binary"
fc /b t.exe s.c
call TAP\wasok "diff binary"
del s.c.zlib
call TAP\wasok "rm self-compressed binary"
del s.c
call TAP\wasok "rm self-uncompressed binary"
del t.s
call TAP\wasok "rm test binary"

.\t.exe t.exe
call TAP\wasok self-compress
call TAP\pathexist t.exe.zlib self-compressed
ren t.exe.zlib t.s.zlib
call TAP\wasok "change uncompressed filename"
call TAP\pathexist t.s.zlib "changed uncompressed filename"
.\t.exe t.s.zlib
call TAP\wasok self-uncompress
call TAP\pathexist t.s self-uncompressed
fc /b t.exe t.s
call TAP\wasok self-diff
del t.s.zlib
call TAP\wasok "rm self-compressed binary"
del t.s
call TAP\wasok "rm self-uncompressed binary"

.\t.exe LICENSE
call TAP\wasok "compress LICENSE"
call TAP\pathexist LICENSE.zlib "compressed LICENSE"
ren LICENSE.zlib s.c.zlib
call TAP\wasok "rename LICENSE.zlib->s.c.zlib"
call TAP\pathexist s.c.zlib "s.c.zlib exists"
.\t.exe s.c.zlib
call TAP\wasok "uncompress LICENSE"
call TAP\pathexist s.c "uncompressed LICENSE"
fc LICENSE s.c
call TAP\wasok "LICENSE diff"
del s.c.zlib
call TAP\wasok "rm compressed LICENSE"
del s.c
call TAP\wasok "rm uncompressed LICENSE"

.\t.exe t.o
call TAP\wasok "compress object file"
call TAP\pathexist t.o.zlib "compressed object file"
ren t.o.zlib t.s.zlib
call TAP\wasok "change uncompressed filename"
call TAP\pathexist t.s.zlib "changed uncompressed filename"
.\t.exe t.s.zlib
call TAP\wasok "uncompress object file"
call TAP\pathexist t.s "uncompressed object file"
fc /b t.o t.s
call TAP\wasok "diff object file"
del t.s.zlib
call TAP\wasok "rm compressed object file"
del t.s
call TAP\wasok "rm uncompressed object file"
del t.o
call TAP\wasok "rm test object file"

del t.exe
call TAP\wasok "rm test binary"
endtests
