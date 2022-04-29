# Times function pointer execution in clock cycles
# Saves benchmark values for further analysis

    .text

    .globl _run_timing
    .p2align 4, 0x90

# Stack layout: counter (4), iterations (4), data (8), init (8), loop (8), old_time (8), n (4)

_run_timing:
    pushq   %rbp                # Sets up stack frame
    movq    %rsp, %rbp
    subq    $48, %rsp           # 4 bytes of padding for 16-byte boundary

    movl    %edx, 40(%rsp)      # "Push" all parameters to stack so they're not clobbered
    movl    %esi, (%rsp)
    rdtsc                       # Interleave setting up initial time
    movl    %esi, 4(%rsp)
    movq    %rdi, 8(%rsp)
    movq    %rcx, 16(%rsp)
    movq    %r8, 24(%rsp)
    movl    %eax, 32(%rsp)      # This can be done as two little-endian dwords
    movl    %edx, 36(%rsp)      # This is why this section is not written as push instructions

mainloop:
    callq   *16(%rsp)           # Call init function pointer on stack

iterationloop:
    callq   *24(%rsp)           # Call loop function pointer on stack
    decl    (%rsp)
    jne     iterationloop

    rdtsc                       # Gets current time
    movq    8(%rsp), %rcx       # Interleave adding entry to data
    shlq    $32, %rax
    addq    $8, 8(%rsp)         # Increase data pointer on stack ahead of time
    shrdq   $32, %rdx, %rax
    movq    32(%rsp), %rsi
    movl    4(%rsp), %edi       # Interleave resetting counter
    movq    %rax, 32(%rsp)      # Save old time
    subq    %rsi, %rax
    movl    %edi, (%rsp)
    movq    %rax, (%rcx)

    decl    40(%rsp)
    jne     mainloop

    leave
    retq

    .globl _null_func
    .p2align 4, 0x90

_null_func:
    retq
