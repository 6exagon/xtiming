//Command line tool to benchmark assembly subroutines
//Mac OS X only, though this could potentially be modified for any POSIX OS

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <inttypes.h>
#include <dlfcn.h>
#include "xtimeutil.h"

//No-operation func for when no init function is present, executing only a retq
extern void null_func(void);

//This function implemented in assembly for rdtsc instruction and custom calling conventions
extern void run_timing(uint64_t *, uint32_t, uint32_t, void (*)(void), void (*)(void));

//Prints statistics about timing data
void print_statistics(uint64_t *data, uint32_t n) {
    qsort(data, n, sizeof(uint64_t), compare);
    printf("Minimum: %" PRIu64, *data);
    printf("\nQ1:      %" PRIu64, data[n >> 2]);
    printf("\nMedian:  %" PRIu64, data[n >> 1]);
    printf("\nQ3:      %" PRIu64, data[n * 3 >> 2]);
    printf("\nMaximum: %" PRIu64, data[n - 1]);
    printf("\nIQR:     %" PRIu64, data[n * 3 >> 2] - data[n >> 2]);
    uint64_t s = sum(data, n);
    printf("\nSum:     %" PRIu64, s);
    long double mean = (long double) s / n;
    printf("\nMean:    %LF", mean);
    printf("\nSTDEV:   %LF\n", stdev(data, n, mean));
}

//Parses command-line flags, prepares and loads .dylib, runs tests, outputs results to stdout
int main(int argc, char *argv[]) {
    uint32_t iterations = UINT16_MAX;
    uint32_t sample_size = UINT16_MAX;
    void (*init_func)(void);
    void (*loop_func)(void);
    void *dylib;
    
    switch (argc) {
        default:
            puts("Usage: xtime filename [samples] [iterations]");
            return 0;
        case 4:
            iterations = (uint32_t) atol(argv[3]);
            if (!iterations) {
                puts("Invalid iteration count value");
                return 0;
            }
        case 3:
            sample_size = (uint32_t) atol(argv[2]);
            if (!sample_size) {
                puts("Invalid sample size value");
                return 0;
            }
        case 2:;
    }
    
    char *command;
    switch (popfiletypeof(argv[1])) {
        default:
            puts("Invalid input file type");
            return 0;
        case ASM:
            command = stradd(5, "as -o '", argv[1], ".o' '", argv[1], ".s'");
            if (!command || system(command)) {
                puts("Error assembling source file");
                free(command);
                return 0;
            }
            free(command);
        case OBJ:
            command = stradd(5, "ld -dylib -lc -o '", argv[1], ".dylib' '", argv[1], ".o'");
            if (!command || system(command)) {
                puts("Error linking object");
                free(command);
                return 0;
            }
            free(command);
        case DYLIB:
            command = stradd(2, argv[1], ".dylib");
            if (!command || !(dylib = dlopen(command, RTLD_LAZY))) {
                puts("Error opening .dylib");
                free(command);
                return 0;
            }
            free(command);
            init_func = dlsym(dylib, "init");
            loop_func = dlsym(dylib, "loop");
            if (!loop_func) {
                puts("Error finding loop function in .dylib");
                dlclose(dylib);
                return 0;
            }
    }
    
    uint64_t *data = malloc(sample_size * sizeof(uint64_t));
    if (!data) {
        puts("Error allocating trial data memory");
        dlclose(dylib);
        return 0;
    }
    run_timing(data, iterations, sample_size, (init_func) ? init_func : null_func, loop_func);
    print_statistics(data, sample_size);
    free(data);
    dlclose(dylib);
    return 0;
}
