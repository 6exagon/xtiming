# Simple proof-of-concept example of memory allocation on the stack
# Handling the return addresses here looks strange, but it's needed for the three-function setup

    .text

    .globl _init
    .p2align 4, 0x90

_init:
    movq    (%rsp), %rax
    subq    $256, %rsp
    movq    %rax, (%rsp)
    retq

    .globl _loop
    .p2align 4, 0x90

_loop:
    subq    $8, %rsp
    leaq    16(%rsp), %rdi
    leaq    sample_string(%rip), %rsi
    callq   _strcpy
    addq    $8, %rsp
    retq

    .globl _destroy
    .p2align 4, 0x90

_destroy:
    movq    (%rsp), %rax
    addq    $256, %rsp
    movq    %rax, (%rsp)
    retq

    .cstring
sample_string:
    .ascii  "This is an example string that's too big to fit into the 128-byte red zone. "
    .ascii  "The contents of the loop function are completely irrelevant to this example. "
    .asciz  "Its modification of %rsp is simply for a 16-byte stack alignment."
