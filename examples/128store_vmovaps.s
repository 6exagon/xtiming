# Example program (storing immediate 128-bit value) using AVX instruction

    .text

    .p2align 4, 0x90

imm128:
    .quad   0xdabdecadedeadfad
    .quad   0xdefacedcafefaded

    .globl _init

_init:
    vmovaps imm128(%rip), %xmm0
    retq

    .globl _loop
    .p2align 4, 0x90

_loop:
    vmovaps %xmm0, -24(%rsp)
    retq
