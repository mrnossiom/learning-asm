CC := clang
CFLAGS := -Wall -Wextra -Wvla

all: more_or_less_c more_or_less_asm

more_or_less_asm: LDFLAGS += -nostdlib -static
more_or_less_asm: more_or_less_asm.o

clean:
	$(RM) -f more_or_less_c more_or_less_c.o
	$(RM) -f more_or_less_asm more_or_less_asm.o

.PHONY: all clean
