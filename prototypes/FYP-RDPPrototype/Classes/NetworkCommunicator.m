//
//  NetworkCommunicator.m
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import "NetworkCommunicator.h"
#import "NSStreamAdditions.h"
#import "RDPCore.h"


@implementation NetworkCommunicator

// These variables are related to the storage of incoming data
uint8_t* data;
BOOL dataIsInitialized;
int dataLength;


@synthesize host;
@synthesize port;
@synthesize rdpcore;


// Estalish connection
- (void)connectToServerUsingStream:(NSString*)urlStr
							portNo:(uint)portNo
{
	if (![urlStr isEqualToString:@""]) {
		NSURL *website = [NSURL URLWithString:urlStr];
		if (!website) {
			NSLog(@"%@ is not a valid URL.");
		}
		else {
			[NSStream getStreamsToHostNamed:urlStr
									   port:portNo
								inputStream:&iStream
							   outputStream:&oStream];
			[iStream retain];
			[oStream retain];
			
			[iStream setDelegate:self];
			[oStream setDelegate:self];
			
			[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
							   forMode:NSDefaultRunLoopMode];
			[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
							   forMode:NSDefaultRunLoopMode];
			
			[oStream open];
			[iStream open];
		}
	}
}


// write buffer to the connected server
- (void) writeToServer:(const uint8_t*)buffer length:(int)length {
	printf("Client message: \n");
	for (int i = 0; i < length; ++i) {
		printf("%i\n",buffer[i]);
	}
	printf("the end of message \n");
	[oStream write:buffer maxLength:length];
}


// Handles events occurred on streams
- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventcode {
	
	switch(eventcode) {
		case NSStreamEventHasBytesAvailable: //There is incoming data
		{
			printf("has bytes available");
			//if (!dataIsInitialized) {
			//	data = malloc(1024);
			//	dataIsInitialized = TRUE;
			//}
			
			uint8_t buffer[1024];
			printf("!!!");
			unsigned int length = 0;
			length = [(NSInputStream*)stream read:buffer maxLength:1024];
			printf("???");
			//if(length) {
			//	printf("^^^");
			//	memcpy(data, buffer, length);
				//dataLength += length;
			//	printf("***");
			//} else {
			//	NSLog(@"No data.");
			//}
			
			printf("%u\n", length);
			if (length > 0) {
				printf("\nServer reply: \n");
				for (int i = 0; i < length; ++i) {
					printf("%i\n", buffer[i]);
				}
			printf("\n");
			printf("sending to parse...");
			[rdpcore ParseMessage:buffer OfLength:length];
			}
			printf("asdsad");
			//data = nil;
			//dataLength = 0;
			//dataIsInitialized = FALSE;
		}
			break;	
	}
}



- (void) sendMessage: (const uint8_t*)str length:(int)length {
	[self connectToServerUsingStream:self.host portNo:self.port];
	[self writeToServer:str length:length];
}



- (BOOL) setHost:(NSString*)hostVal 
			port:(NSInteger)portVal {
	self.host = hostVal;
	self.port = portVal;
	
	if (host == nil) {
		return FALSE;
	}
	if ( (port < 0) || (port > 65536) ) {
		return FALSE;
	}	
	
	return TRUE;
}


- (id) initWithRDPCore:(RDPCore*)rdpCorePtr {
	[super init];
	dataIsInitialized = FALSE;
	dataLength = 0;
	self.rdpcore = rdpCorePtr;
	return self;
}

- (void) disconnect {
	[iStream close];
	[oStream close];
}

- (void) dealloc {
	[self disconnect];
		
	[iStream release];
	[oStream release];
	
    [super dealloc];
}


@end
