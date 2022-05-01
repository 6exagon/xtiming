# XTiming

A simple command-line tool to benchmark user-defined assembly subroutines on Mac OS X. This may be used to test efficiency of algorithms or processor instruction sequences in context.

## Setup

#### Requirements

As the name implies, this project will only work on Mac, though it could potentially be modified to run on any POSIX OS. However, no third-party tools are required, and the program executable is standalone once built.

#### Compilation & Installation

Download and decompress this project's .zip file or clone its source tree, then `cd` into the main directory and run `make`. The program executable should then be created in the `build` directory, and it can be moved to `/usr/local/bin` if desired.

## Use

#### Purpose

Finding the throughput, micro-operation count, and latency of singular instructions can be useful, but context heavily qualifies all of this information. In addition, algorithm overhead vs. overall performance can be difficult to pinpoint. In a lot of cases, timing entire assembly subroutines in clock cycles is the most useful thing to do, but it can be difficult to deal with the amount of boilerplate and complicated system-specific hacks needed to get even a basic timing setup working.

XTiming is designed to make sense and be easy to use. It simply loads a dynamic library and benchmarks its performance in clock cycles (using `rdtsc` as a timing mechanism). Each test consists of running its  `init` function, many iterations of its `loop` function, and its `destroy` function. Finally, several statistics will be printed about the dataset.

Examples can be found in the `examples` directory, and with XTiming they demonstrate that (on certain machines at least) though the initial overhead of loading a large constant into `%xmm0` is great, it stops outweighing the tiny penalty of two `mov`'s per loop as the number of loops increases past a certain threshold.

#### Basic Usage

Run the program from the command line:

`$ xtime filename [samples] [iterations]`

The filename should be a .dylib with a `loop` function (and optionally  `init` and/or `destroy` functions). Alternatively, provide a .s or .o file which will be assembled and linked into a dynamic library.

Sample size and iteration count are optional and default to `UINT16_MAX`. Sample size specifies the number of samples taken, and iteration count specifies the number of times the `loop` function should be run between the `init` and `destroy` functions per sample.

Again, examples can be found in the `examples` directory.

#### Advanced Behaviors

Between the calls to the `init` and `destroy` functions within each benchmark test, `xtime` will neither rely on nor overwrite any registers. The user is free to use all of them as they wish without preservation. There are only a few exceptions to this:

- Most of the flags register will be overwritten between function calls
- The base pointer (`%rbp`) must be preserved by each function
- The stack pointer (`%rsp`) may be overwritten at any point during a benchmark test, but it must be returned to its original position by the end of the `destroy` function (there is an example of this in the `examples` folder)

Between benchmark tests, some registers will be overwritten.

The C POSIX Library (libc) may be used, but keep in mind that heavy use of libc may make benchmark statistics less obvious and consistent.

If necessary, the red zone of 128 bytes beneath the stack pointer (per the System V AMD64 ABI) may be used for permanent storage between function calls in addition to registers, or more memory can be allocated by syscalls/libc or on the stack (take care to avoid memory leaks).

Remember to ensure byte alignment where applicable (as in the vmovaps example).

Do not specify sample sizes or iteration counts larger than `UINT32_MAX`; they will (safely) overflow to fit within this bound.

The .s/.o/.dylib filename must not have a single quote character in it, as this cannot be properly escaped within a single quote string in bash.

## Contributions

#### Suggestions

Anyone testing the code and reporting bugs or suggesting improvements in the issue tracker is very welcome! Though obviously executing arbitrary code completely eliminates the possibility of security, vulnerabilities in the code are still undesirable.

## License

This software is released under the MIT License. Please see the [license](LICENSE.txt) for more details.
