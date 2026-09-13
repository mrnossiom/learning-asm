.intel_syntax noprefix

        SYS_EXECVE      = 0x3b
        SYS_EXIT        = 0x3c

.text

.global _start
_start:
        mov rax, offset SYS_EXECVE
        lea rdi, [rip + sh_arg0]
        lea rsi, [rip + argv]
        mov rdx, 0
        call notsyscall

        mov rax, offset SYS_EXIT
        mov rdi,1
        call notsyscall

sh_arg0:        .asciz "/bin/sh"
sh_arg1:        .asciz "-c"
sh_arg2:        .asciz "echo Hello"

argv:
        .quad sh_arg0
        .quad sh_arg1
        .quad sh_arg2
        .quad 0

notsyscall:
        mov rax, rdi
        mov rdi, rsi
        mov rsi, rdx
        mov rdx, rcx

        syscall
        ret
