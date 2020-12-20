/* zdrop.c:
released under Creative Commons Attribution (BY) 4.0 license
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
made by PC-XT of MajorGeeks.com for
http://forums.majorgeeks.com/index.php?threads/zlib-uncompression-for-an-idiot.223640/
Please report bugs at https://github.com/Quasic/zdrop/issues
based on public domain zpipe.c Version 1.4 (11 December 2005) by Mark Adler */

/* Version history:
   0.1   4 Oct 2010  Quick first version, tested with zlib-1.2.5, everything but main() from zpipe.c
   0.2   5 Oct 2010  Fixed first bug, cleaned up a bit
   1.0   5 Oct 2014  Refined code, fixed crash on file doesn't exist bug, added .z extension support, tested with zlib-1.2.8
   1.1  16 Dec 2015  Cleaned up code for source release
   1.2  18 Dec 2020  Report VERSION, ZLIB_VERSION, fix internal error# report
*/
#define VERSION "1.2"

/*Windows bugs:
The console doesn't stay onscreen long enough to read error messages.
Old versions of windows may use short filenames, so new files may need renaming.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "zlib.h"

#define CHUNK 16384

/* Compress from file source to file dest until EOF on source.
   def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_STREAM_ERROR if an invalid compression
   level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
   version of the library linked do not match, or Z_ERRNO if there is
   an error reading or writing the files. */
void fexists(char*n){
  fputs("The file '",stderr);
  fputs(n,stderr);
  fputs("' already exists.\0Please delete or rename it before trying this again.",stderr);
}
int def(FILE *source, FILE *dest, int level)
{
    int ret, flush;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    /* allocate deflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    ret = deflateInit(&strm, level);
    if (ret != Z_OK)
        return ret;

    /* compress until end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)deflateEnd(&strm);
            return Z_ERRNO;
        }
        flush = feof(source) ? Z_FINISH : Z_NO_FLUSH;
        strm.next_in = in;

        /* run deflate() on input until output buffer not full, finish
           compression if all of source has been read in */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = deflate(&strm, flush);    /* no bad return value */
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)deflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);
        assert(strm.avail_in == 0);     /* all input will be used */

        /* done when last data in file processed */
    } while (flush != Z_FINISH);
    assert(ret == Z_STREAM_END);        /* stream will be complete */

    /* clean up and return */
    (void)deflateEnd(&strm);
    return Z_OK;
}

/* Decompress from file source to file dest until stream ends or EOF.
   inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_DATA_ERROR if the deflate data is
   invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
   the version of the library linked do not match, or Z_ERRNO if there
   is an error reading or writing the files. */
int inf(FILE *source, FILE *dest)
{
    int ret;
    unsigned have;
    z_stream strm;
    unsigned char in[CHUNK];
    unsigned char out[CHUNK];

    /* allocate inflate state */
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    strm.opaque = Z_NULL;
    strm.avail_in = 0;
    strm.next_in = Z_NULL;
    ret = inflateInit(&strm);
    if (ret != Z_OK)
        return ret;

    /* decompress until deflate stream ends or end of file */
    do {
        strm.avail_in = fread(in, 1, CHUNK, source);
        if (ferror(source)) {
            (void)inflateEnd(&strm);
            return Z_ERRNO;
        }
        if (strm.avail_in == 0)
            break;
        strm.next_in = in;

        /* run inflate() on input until output buffer not full */
        do {
            strm.avail_out = CHUNK;
            strm.next_out = out;
            ret = inflate(&strm, Z_NO_FLUSH);
            assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
            switch (ret) {
            case Z_NEED_DICT:
                ret = Z_DATA_ERROR;     /* and fall through */
            case Z_DATA_ERROR:
            case Z_MEM_ERROR:
                (void)inflateEnd(&strm);
                return ret;
            }
            have = CHUNK - strm.avail_out;
            if (fwrite(out, 1, have, dest) != have || ferror(dest)) {
                (void)inflateEnd(&strm);
                return Z_ERRNO;
            }
        } while (strm.avail_out == 0);

        /* done when inflate() says it's done */
    } while (ret != Z_STREAM_END);

    /* clean up and return */
    (void)inflateEnd(&strm);
    return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
}

/* compress or decompress from stdin to stdout */
int main(int argc, char ** argv) {
	if (argc == 2) {
		FILE * f = fopen(argv[1], "rb");
		if (f == NULL) {
			fputs("ERROR: ", stdout);
			fputs(argv[1], stdout);
			fputs(" can't be opened.", stdout);
			return Z_ERRNO;
		}
		FILE * f2;
		const char zext[] = ".z\0",
			zlibext[] = ".zlib\0",
			nl[] = "\n\0",
			er[] = "error reading \0",
			ew[] = "error writing \0";
		const int zL = strlen(zlibext);
		int ret,
		L = strlen(argv[1]),
		L2 = strlen(zext);
		if (strcmp(argv[1] + (L - L2), zext) == 0 || strcmp(argv[1] + (L - (L2 = zL)), zlibext) == 0) {
			argv[1][L - L2] = '\0';
			f2 = fopen(argv[1], "rb");
			if (f2 != NULL) {
				fclose(f);
				fclose(f2);
				fexists(argv[1]);
				return -12;
			}
			fputs("Decompressing ", stdout);
			fputs(argv[1], stdout);
			fputs(" from ", stdout);
			fputs(argv[1], stdout);
			fputs(L2 == zL ? zlibext : zext, stdout);
			fputs("...", stdout);
			f2 = fopen(argv[1], "wb");
			ret = inf(f, f2);
			if (ret == Z_ERRNO) {
				if (ferror(f))
					fputs(er, stderr);
				fputs(argv[1], stderr);
				fputs(L2 == zL ? zlibext : zext, stderr);
				fputs(nl, stderr);
				if (ferror(f2))
					fputs(ew, stderr);
				fputs(argv[1], stderr);
				fputs(nl, stderr);
			}
		} else {
			char * n = malloc(L + L2 + 1);
			if (n == NULL) {
				fputs("Error: Out of Memory", stderr);
				return Z_MEM_ERROR;
			}
			n[0] = '\0';
			strcat(n, argv[1]);
			strcat(n, L2 == zL ? zlibext : zext);
			f2 = fopen(n, "rb");
			if (f2 != NULL) {
				fclose(f);
				fclose(f2);
				fexists(n);
				free(n);
				return -12;
			}
			fputs("Compressing ", stdout);
			fputs(argv[1], stdout);
			fputs(" into ", stdout);
			fputs(n, stdout);
			fputs("...", stdout);
			f2 = fopen(n, "wb");
			free(n);
			ret = def(f, f2, Z_DEFAULT_COMPRESSION);
			if (ret == Z_ERRNO) {
				if (ferror(f))
					fputs(er, stderr);
				fputs(argv[1], stderr);
				fputs(nl, stderr);
				if (ferror(f2))
					fputs(ew, stderr);
				fputs(n, stderr);
				fputs(nl, stderr);
			}
		}
		fclose(f);
		fclose(f2);
		switch (ret) {
		case Z_OK:break;
			//case Z_ERRNO:
			//handled already
			//break;
		case Z_DATA_ERROR:
			fputs("invalid or incomplete deflate data\n", stderr);
			break;
		case Z_MEM_ERROR:
			fputs("out of memory\n", stderr);
			break;
			//case Z_STREAM_ERROR:
			//fputs("invalid compression level\n", stderr);
			//break;
			//not used in static compile
			//case Z_VERSION_ERROR:
			//fputs("zlib version mismatch!\n", stderr);
			//break;
			//not used in static compile
		default:
			fprintf(stderr,"Internal error #%i\n",ret);
		}
		return ret;
	}
	/* otherwise, report usage */
	fprintf(stderr,"zdrop version %s (ZLIB version %s)\
Usage: give a zlib file (*.z or *.zlib) to decompress\
or any other file to compress to a file with a .zlib extension\
(Not all *.z files are zlib. Some are archives that WinZip or WinRAR can open.)\n",VERSION,ZLIB_VERSION);
	return 10;
}
/* %ERRORLEVEL%
#define Z_OK            0
#define Z_STREAM_END    1
#define Z_NEED_DICT     2
#define Z_ERRNO        (-1)
#define Z_STREAM_ERROR (-2)
#define Z_DATA_ERROR   (-3)
#define Z_MEM_ERROR    (-4)
#define Z_BUF_ERROR    (-5)
#define Z_VERSION_ERROR (-6)

help display (as in parameter error, no other action taken) -10
error opening input file -11
destination file exists -12
 */
