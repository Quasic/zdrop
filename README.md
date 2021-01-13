# zdrop
Drag and drop zlib format compressor and decompressor for Windows

# Installation
Either download a release executable or compile one.

Installation is drag&drop: just drag the file where you want it.

# Uninstallation
Just delete the program file. No registry items or setup files are created by this program, simplifying removal.

# Compiling
Requires zlib.h and libz.a from your system's zlib (or zlib-dev) package, or from [zlib.net](//zlib.net)

If you have make, run ```make test``` then ```make install```

If you have an IDE, open zdrop.c and add zlib.h and libz.a

If you have gcc with zlib installed properly, (run ```gcc -print-file-name=libz.a``` to find <libzpath> then run ```gcc zdrop.c <libzpath> -o zdrop.exe```
You should be able to use -O3 and -fexpensive-optimizations if you like.

# History
This program was made as an answer for [a MajorGeeks.com forum question](//forums.majorgeeks.com/index.php?threads/zlib-uncompression-for-an-idiot.223640/)
