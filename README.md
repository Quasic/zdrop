# zdrop
Drag and drop zlib format compressor and decompressor for Windows

# Installation
Either download a release executable or compile one. (See below.)

Installation is drag&drop: just drag the file where you want it.

# Uninstallation
Just delete the program file. No registry items or setup files are created by this program, simplifying removal.

# Compiling
Requires zlib.h and libz.a from your system's zlib (or zlib-dev) package, or from [zlib.net](//zlib.net)

If you have gcc, run t/zdrop.c.bat to test, then makegcc.bat to open a window with the executable, which you can drag where you want to use it.

If you have an IDE, open zdrop.c and add zlib.h and libz.a

If you want to use make, run ```make test``` then ```make install```

# History
This program was made as an answer for [a MajorGeeks.com forum question](//forums.majorgeeks.com/index.php?threads/zlib-uncompression-for-an-idiot.223640/)
from a zlib example public domain source [zpipe.c](//zlib.net/zpipe.c).
