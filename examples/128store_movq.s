# Example program (storing immediate 128-bit value) using regular movq

    .text

    .globl _init
    .p2align 4, 0x90

_init:
    movq    $0xdabdecadedeadfad, %rax
    movq    $0xdefacedcafefaded, %rbx
    retq

    .globl _loop
    .p2align 4, 0x90

_loop:
    movq    %rax, -24(%rsp)
    movq    %rbx, -16(%rsp)
    retq
