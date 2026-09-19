CC := clang
CFLAGS := -std=c99 -pedantic -Wall -Wextra -Wvla -O0

CFLAGS += -fsanitize=address -g3

all: execve_c execve_asm offset target

execve_asm: LDFLAGS += -nostdlib -static
execve_asm: execve_asm.o

clean:
	$(RM) -f execve_c execve_c.o
	$(RM) -f execve_asm execve_asm.o
	$(RM) -f offset target

.PHONY: all clean
