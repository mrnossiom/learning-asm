#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

int main(void) {
  long long base_addr = (size_t)malloc;
  // long long base_addr = (size_t)printf;
  // long long base_addr = (size_t)puts;
  long long target_addr = (size_t)mmap;
  printf("%lld\n", target_addr - base_addr);

  printf("mmap flags: %d, %d\n", PROT_READ | PROT_WRITE | PROT_EXEC,
         MAP_PRIVATE | MAP_ANONYMOUS);
}
