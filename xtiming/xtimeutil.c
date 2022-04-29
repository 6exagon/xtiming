//Utility functions for the main timing program

#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <string.h>
#include <math.h>
#include "xtimeutil.h"

//Returns and truncates the file extension of a filename
enum filetype popfiletypeof(char *filename) {
    char *dot = strrchr(filename, '.');
    if (!dot) {
        return OTHER;
    }
    *dot++ = 0;
    if (!strcmp(dot, "s")) {
        return ASM;
    }
    if (!strcmp(dot, "o")) {
        return OBJ;
    }
    if (!strcmp(dot, "dylib")) {
        return DYLIB;
    }
    return OTHER;
}

//Returns result of strcat in heap buffer large enough for any number of strings
char *stradd(int num,...) {
    va_list valist;
    va_start(valist, num);
    int total_len = 1;
    for (int x = 0; x < num; x++) {
        total_len += strlen(va_arg(valist, char *));
    }
    va_end(valist);
    char *result = malloc(total_len);
    if (result) {
        *result = 0;
        va_start(valist, num);
        for (int x = 0; x < num; x++) {
            strcat(result, va_arg(valist, char *));
        }
        va_end(valist);
    }
    return result;
}

//Safe overflow-free comparison function for use in qsort
int compare(const void *ptr_a, const void *ptr_b) {
    uint64_t a = *(uint64_t *) ptr_a;
    uint64_t b = *(uint64_t *) ptr_b;
    return (a > b) - (a < b);
}

//Sums data block (may be rewritten in assembly in the future)
uint64_t sum(uint64_t *data, uint32_t n) {
    uint64_t s = 0;
    while (n--) {
        s += data[n];
    }
    return s;
}

//Calculates sample standard deviation of memory block given its mean
long double stdev(uint64_t *data, uint32_t n, long double mean) {
    long double ssquares = 0.0;
    for (uint32_t x = 0; x < n; x++)  {
        long double diff = data[x] - mean;
        ssquares += diff * diff;
    }
    return sqrtl(ssquares / (n - 1));
}
