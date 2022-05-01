# Times function pointer execution in clock cycles
# Saves benchmark values for further analysis

    .text

    .globl _run_timing
    .p2align 4, 0x90

# Stack layout:
# counter (4), iterations (4), data (8), init (8), loop (8), destroy (8), old_time (8), n (4),
# padding (4), %r12 (8), %r13 (8), %r14 (8), %r15 (8), %rbx (8)

_run_timing:
    pushq   %rbp                # Sets up stack frame
    movq    %rsp, %rbp
    subq    $96, %rsp           # Includes 4 bytes of padding for 16-byte boundary

    movl    %edx, 48(%rsp)      # "Push" all parameters to stack so they're not clobbered
    movl    %esi, (%rsp)
    rdtsc                       # Interleave setting up initial time
    movl    %esi, 4(%rsp)
    movq    %rdi, 8(%rsp)
    movq    %rcx, 16(%rsp)
    movq    %r8, 24(%rsp)
    movq    %r9, 32(%rsp)
    movl    %eax, 40(%rsp)      # This can be done as two little-endian dwords
    movl    %edx, 44(%rsp)      # This is why this section cannot be written as push instructions
    movq    %r12, 56(%rsp)      # That would be slower anyway though, judging from other sources
    movq    %r13, 64(%rsp)      # Operating system interrupt register push code often does this
    movq    %r14, 72(%rsp)
    movq    %r15, 80(%rsp)
    movq    %rbx, 88(%rsp)

mainloop:
    callq   *-80(%rbp)          # Call init function pointer on stack

iterationloop:
    callq   *-72(%rbp)          # Call loop function pointer on stack
    decl    -96(%rbp)
    jne     iterationloop

    callq   *-64(%rbp)          # Call destroy function pointer on stack

    rdtsc                       # Gets current time
    movq    8(%rsp), %rcx       # Interleave adding entry to data
    shlq    $32, %rax
    addq    $8, 8(%rsp)         # Increase data pointer on stack ahead of time
    shrdq   $32, %rdx, %rax
    movq    40(%rsp), %rsi
    movl    4(%rsp), %edi       # Interleave resetting counter
    movq    %rax, 40(%rsp)      # Save old time
    subq    %rsi, %rax
    movl    %edi, (%rsp)
    movq    %rax, (%rcx)

    decl    48(%rsp)
    jne     mainloop

    movq    56(%rsp), %r12      # Restore callee-preserved registers
    movq    64(%rsp), %r13
    movq    72(%rsp), %r14
    movq    80(%rsp), %r15
    movq    88(%rsp), %rbx

    leave
    retq

    .globl _null_func
    .p2align 4, 0x90

_null_func:
    retq
