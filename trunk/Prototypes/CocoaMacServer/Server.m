//
//  Server.m
//  CocoaMacServer
//
//  Created by Guo Hua on 01/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import "Server.h"


#include <CoreServices/CoreServices.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>


@interface Server ()

@property (nonatomic, assign) CFSocketRef listeningSocket;
@property (nonatomic, retain) NSInputStream* networkStream;

@end


@implementation Server


@synthesize listeningSocket;
@synthesize networkStream;


- (void)_startServer
{
	BOOL success;
	int err;
	int fd; //representation of the socket
	int junk;
	struct sockaddr_in addr; //representation of the target address
	int port;

	port = 0;
	// create the socket
	fd = socket(AF_INET, SOCK_STREAM, 0);
	success = (fd != -1);
	
	// create address representation
	if (success) {
		memset(&addr, 0, sizeof(addr));
		addr.sin_len = sizeof(addr);
		addr.sin_family = AF_INET;
		addr.sin_port = 0;
		addr.sin_addr.s_addr = INADDR_ANY;
		err = bind(fd, (const struct sockaddr*)&addr, sizeof(addr));
		success = (err == 0);
	}
	
	if (success) {
		err = listen(fd, 5);
		success = (err == 0);
	}
	
	if (success) {
		socklen_t addrLen;
		addrLen = sizeof(addr);
		err = getsockname(fd, (struct sockaddr*)&addr, &addrLen);
		success = (err == 0);
		if (success) {
			assert(addrLen == sizeof(addr));
			port = ntohs(addr.sin_port);
		}
	}
	
	// create the CFSocket wrapper of the BSD socket
	if (success) {
		CFSocketContext context = {0, self, NULL, NULL, NULL};
		self.listeningSocket = CFSocketCreateWithNative(
														NULL,
														fd,
														kCFSocketAcceptCallBack,
														AcceptCallback,
														&context
														);
		success = (self.listeningSocket != NULL);
		
		if (success) {
	//		CFRunLoopSource
		}
	}
}
	

@end