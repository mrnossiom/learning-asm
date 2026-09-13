#include <sys/syscall.h>
#include <unistd.h>

void run_script(void) {
  char *argv[] = {
      "/usr/bin/env", "sh", "-c", "echo Hello", 0,
  };
  // syscall(SYS_execve, argv[0], argv, 0);
  execve(argv[0], argv, 0);
}

int main(void) { run_script(); }
