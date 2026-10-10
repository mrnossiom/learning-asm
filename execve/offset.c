#include <dlfcn.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <unistd.h>

int main(void) {
  size_t base_addr = (size_t)malloc;
  // size_t base_addr = (size_t)printf;
  // size_t base_addr = (size_t)puts;
  size_t target_addr = (size_t)mmap;
  // size_t target_addr = (size_t)mprotect;
  // size_t target_addr = (size_t)execve;
  // size_t target_addr = (size_t)system;
  // size_t target_addr = (size_t)dlsym;

  printf("main          : %zu\n", (size_t)main);
  printf("target - base : %td\n", (ptrdiff_t)(target_addr - base_addr));
  printf("mmap consts   : prot(%d) flags(%d)\n",
         PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS);
}
