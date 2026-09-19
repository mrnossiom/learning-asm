#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

union notmmap_build {
  int (*basefn)(const char *);
  size_t addr;
  void *(*fn)(void *addr, size_t length, int prot, int flags, int fd,
              off_t offset);
};

union notsyscall_build {
  char *memory_ptr;
  int (*fn)();
};

#define BUILD(Name, BaseFn, Offset)                                            \
  union Name##_build Name = {.basefn = BaseFn};                                \
  Name.addr = Name.addr Offset;

int main(void) {
  BUILD(notmmap, puts, +1905)

  char *argv[] = {
      "/bin/sh",
      "-c",
      "echo foo",
      NULL,
  };

  // clang-format off
  unsigned char instructions[] = {
      // notsyscall: translate System V C ABI to Linux syscall ABI
      0x48, 0x89, 0xf8,   // mov    %rdi,%rax
      0x48, 0x89, 0xf7,   // mov    %rsi,%rdi
      0x48, 0x89, 0xd6,   // mov    %rdx,%rsi
      0x48, 0x89, 0xca,   // mov    %rcx,%rdx
      0x0f, 0x05,         // syscall
      0xc3,               // ret
  };
  // clang-format on

  char *code = notmmap.fn(NULL, sizeof(instructions) / sizeof(char),
                          PROT_READ | PROT_WRITE | PROT_EXEC,
                          MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (code == (void *)-1) {
    perror("could not map page");
    exit(1);
  }

  // copy program
  for (size_t idx = 0; idx < sizeof(instructions); idx++) {
    code[idx] = instructions[idx];
  }

  union notsyscall_build notsyscall = {.memory_ptr = code};

  notsyscall.fn(59, argv[0], argv, NULL);
  notsyscall.fn(60, 43);
}
