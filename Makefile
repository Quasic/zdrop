CFLAGS= -fexpensive-optimizations -O3 -pipe
CC= gcc
Version:=$(shell awk -v verStr='zdrop Makefile 1.0' -f getver.awk zdrop.c)
libzpath=$(shell $(CC) -print-file-name=libz.a)

all: test clean install

clean:
	rm -f zdrop.exe
	rm -rf bin

test: zdrop.c libz.a
	bash t/zdrop.c.sh

libz.a:
	@if [ 'libz.a' = "$(libzpath)" ];then echo 'Missing zlib.h or libz.a are solved by installing zlib (or zlib-dev).';false;else true;fi

zdrop.exe: zdrop.c libz.a
	$(CC) zdrop.c "$(libzpath)" -o zdrop.exe $(CFLAGS) -pass-exit-codes

help:
	@echo "Usage: make [test|install|release]"
	@echo "Run in Cygwin or Msys, or load zdrop.c in an IDE and include zlib.h and libz.a"
	@echo "Installation: Since this is a compact file for Windows, simply drag the zdrop.exe file icon wherever you want to use it."
	@echo "To uninstall, just delete the program file"
	@echo "Please report bugs at https://github.com/quasic/zdrop/issues"
	@echo "zdrop was originally an answer for this topic:"
	@echo "http://forums.majorgeeks.com/index.php?threads/zlib-uncompression-for-an-idiot.223640/"
	@echo "Released under Creative Commons Attribution (BY) 4.0 license"

.PHONY: all clean test help install uninstall release

bin:
	mkdir -p bin

# explorer gives exit code 1, so follow with another command

install: zdrop.exe help bin
	explorer bin;mv zdrop.exe bin

uninstall: help

release: clean zdrop.exe bin
	explorer bin;mv zdrop.exe bin/zdrop-$(Version).exe
