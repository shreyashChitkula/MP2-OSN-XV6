// user/syscount.c
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

char *syscall_names[] = {
    "", "fork", "exit", "wait", "pipe", "read", "kill", "exec",
    "fstat", "chdir", "dup", "getpid", "sbrk", "sleep", "uptime",
    "open", "write", "mknod", "unlink", "link", "mkdir", "close",
    "waitx", "getsyscount", // Add the new syscall name
};

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        fprintf(2, "Usage: syscount <mask> command [args]\n");
        exit(1);
    }

    int mask = atoi(argv[1]);

    // Reset the syscall count
    getsyscount(mask);

    int pid = fork();
    if (pid < 0)
    {
        fprintf(2, "fork failed\n");
        exit(1);
    }

    if (pid == 0)
    {
        // Child process
        exec(argv[2], &argv[2]);
        fprintf(2, "exec %s failed\n", argv[2]);
        exit(1);
    }
    else
    {
        // Parent process
        wait(0);
        int count = getsyscount(mask);

        // Get syscall name
        char *syscall_name = "unknown";
        for (int i = 1; i < 24; i++)
        { // we have 23 syscalls now
            if (mask == (1 << i))
            {
                syscall_name = syscall_names[i];
                break;
            }
        }

        printf("PID %d called %s %d times\n", pid, syscall_name, count);
    }
    exit(0);
}