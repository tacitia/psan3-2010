#include <stdio.h>
#include <CoreServices/CoreServices.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

int main (int argc, const char * argv[]) {
    // insert code here...
    printf("Hello, World!\n");
    return 0;
}

void startServer() {
	unsigned char success;
	int err;
	int fd;
	int junk;
	struct sockaddr_in addr;
	int port;
}