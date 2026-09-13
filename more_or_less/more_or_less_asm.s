.intel_syntax noprefix

# FOR	: x86_64-unknown-linux
# BY	: mrnossiom

# order of register arguments are
# %rdi %rsi %rdx %rcx %r8 %r9 +stack
# return in %rax

# https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
# http://unixwiz.net/techtips/x86-jumps.html
# https://www.felixcloutier.com/x86/jcc

	## file descriptors
	FD_STDIN	= 0
	FD_STDOUT	= 1
	FD_STDERR	= 2

	## ret:%rax	(0:%rdi)	(1:%rsi)	(2:%rdx)

	# ssize_t	int		char		size_t
	# count read	fd		*buf		count
	SYS_READ	= 0

	# ssize_t       int		char[]		size_t
	# count wrote	fd 		*buf		count
	SYS_WRITE	= 1

	# 		error_code
	# [[noreturn]]	int
	SYS_EXIT	= 60

	# success	timeval		timezone
	# int		struct		struct
	SYS_GETTIMEOFDAY	= 96

	# success	*buf		count		flags
	# int		char[]		size_t		unsized int
	SYS_GETRANDOM	= 318

.text
.global _start
_start:
main:
	# entry point of program
	# ARGS ( 0 ) : (  )
	# RETURN     : *IGNORE RETURN*

	mov rax, offset SYS_WRITE
	mov rdi, offset FD_STDOUT
	lea rsi, [rip + welcome_msg]
	mov rdx, offset WELCOME_MSG_LEN
	syscall

	# random_num = random_number(1000)
	mov rdi, 1000
	call random_number
	push rax	# save random_num

	.L_prompt:
	# num = prompt()
	call prompt_number

	pop r9
	sub rax, r9
	jg .L_num_below
	jb .L_num_above
	jmp .L_win	# default equal case is win

	.L_num_above:
	push r9
	mov rax, offset SYS_WRITE
	mov rdi, offset FD_STDOUT
	lea rsi, [rip + number_above_msg]
	mov rdx, offset NUMBER_ABOVE_MSG_LEN
	syscall

	jmp .L_prompt

	.L_num_below:
	push r9
	mov rax, offset SYS_WRITE
	mov rdi, offset FD_STDOUT
	lea rsi, [rip + number_below_msg]
	mov rdx, offset NUMBER_BELOW_MSG_LEN
	syscall

	jmp .L_prompt

	.L_win:
	mov rax, offset SYS_WRITE
	mov rdi, offset FD_STDOUT
	lea rsi, [rip + won_msg]
	mov rdx, offset WON_MSG_LEN
	syscall

	# exit()
	call exit

random_number:
	# uses current time of day to generate a pseudo-random number
	# between specified bounds
	#
	# ARGS	: (int upper_bound)
	# RET	: (int random_num)

	push rbp	# preserve previous stack frame address
	mov rbp, rsp	# save current stack frame address
	# from now on, rsp is what you offset from to access the function stack

	# TODO: try to save and retrive on the stack
	mov r8, rdi	# save upper_bound

	# reserve space for timeval {int seconds, int microseconds}
	sub rsp, 2*4
	# gettimeofday(&rbp, &rbp[2*4])
	mov rax, offset SYS_GETTIMEOFDAY
	mov rdi, rsp
	mov rsi, 0	# ignore tz
	syscall

	mov rax, [rsp+4]
	mov rdx, 0
	mov rdi, r8	# retrive upper_bound
	div rdi		# a = bq+r → q:rax, r:rdx

	mov rax, rdx

	add rax, 1	# (0..upper_bound-1) -> (1..upper_bound)

	mov rsp, rbp
	pop rbp
	ret

prompt_number:
	# writes string to stdout point of program
	# ARGS	: (  )
	# RET	: int user_number (<0 is error case)

	push rbp

	# written_buffer_len = read(fd_stdin, &read_buffer, read_buffer_len)
	mov rax, offset SYS_READ
	mov rdi, offset FD_STDIN
	lea rsi, [rip + read_buffer]
	mov rdx, offset READ_BUFFER_LEN
	syscall

	# parse_number(&read_buffer, written_buffer_len)
	lea rdi, [rip + read_buffer]
	mov rsi, rax		# save written buffer length
	call parse_number

	# return rax from parse_number

	pop rbp
	ret

parse_number:
	# writes string to stdout point of program
	# ARGS	: (char *buffer, usize len)
	# RET	: int len (<0 is error case)

	push rbp

	dec rsi		# ignore newline at the end

	mov r9, 0	# index
	mov r8, 0	# result

	.L_loop:
	mov bl, byte ptr [rdi+r9]

	# '0' = 48, '9' = 57
	sub rbx, 48
	jb .L_error	# jump err if char is below '0'
	# TODO: case number is upper

	# rax = r8 * 10 + rax
	mov rax, r8
	mov rcx, 10
	mul rcx		# rax * rcx = rdx:rax (rdx contains upper result bits)
	add rax, rbx

	mov r8, rax

	inc r9		# increment loop index

	mov rax, r9
	sub rax, rsi	# compare to read len
	jne .L_loop

	mov rax, r8

 	pop rbp
	ret

	.L_error:
	mov rax, -1

	pop rbp
	ret

exit:
	# end of program
	# ARGS	: (  )
	# RET	: *IGNORE RETURN*

	mov rdi, 0		# exit code for this program's process
	mov rax, offset SYS_EXIT
	syscall
	nop

.data
	welcome_msg:	.ascii "Welcome to more or less, the most original game in the far west!\n"
	WELCOME_MSG_LEN	= . - welcome_msg

	number_above_msg:	.ascii "Number is higher\n"
	NUMBER_ABOVE_MSG_LEN	= . - number_above_msg
	number_below_msg:	.ascii "Number is lower\n"
	NUMBER_BELOW_MSG_LEN	= . - number_below_msg

	won_msg:	.ascii "You won! pew pew pew\n"
	WON_MSG_LEN	= . - won_msg

.bss
	read_buffer:	.space 20
	READ_BUFFER_LEN	= . - read_buffer
