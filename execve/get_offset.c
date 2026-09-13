#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>

int main(void) {
  long long malloc_addr = (size_t)malloc;
  long long mmap_addr = (size_t)mmap;
  printf("%lld\n", mmap_addr - malloc_addr);
}
