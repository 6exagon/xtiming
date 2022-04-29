#ifndef XTIMEUTIL_H
#define XTIMEUTIL_H

#include <stdint.h>
#include <stdarg.h>

enum filetype {OTHER, ASM, OBJ, DYLIB};

enum filetype popfiletypeof(char *);
char *stradd(int num,...);
int compare(const void *, const void *);
uint64_t sum(uint64_t *, uint32_t);
long double stdev(uint64_t *, uint32_t, long double);

#endif
