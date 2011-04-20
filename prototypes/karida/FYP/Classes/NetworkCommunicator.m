//
//  NetworkCommunicator.m
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import "NetworkCommunicator.h"
#import "NSStreamAdditions.h"
#import "VNCCore.h"

@implementation NetworkCommunicator

// These variables are related to the storage of incoming data
uint8_t* data;
BOOL dataIsInitialized;
int dataLength;

@synthesize vnccore, delegate;


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
			printf("connected \n");
		}
	}
}


// write buffer to the connected server

- (void) writeToServer:(const uint8_t*)buffer length:(int)length {
	//printf("Client message: \n");
	//for (int i = 0; i < length; ++i) {
	//	printf("%i\n",buffer[i]);
	//}
	//printf("the end of message \n");
//	printf("outgoing packet length: %i\n", length);
	[oStream write:buffer maxLength:length];
}


// Handles events occurred on streams
- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventcode {
	
	switch(eventcode) {
		case NSStreamEventHasBytesAvailable: //There is incoming data
		{
			//printf("has bytes available");
			//if (!dataIsInitialized) {
			//	data = malloc(1024);
			//	dataIsInitialized = TRUE;
			//}
//			printf("has bytes available");
			
			uint8_t buffer[3000];
			unsigned int length = 0;
			length = [(NSInputStream*)stream read:buffer maxLength:1500];
			//if(length) {
			//	memcpy(data, buffer, length);
			//dataLength += length;
			//} else {
			//	NSLog(@"No data.");
			//}
			
			//printf("%u\n", length);
			if (length > 0) {
				//	printf("\nServer reply: \n");
				//	for (int i = 0; i < length; ++i) {
				//		printf("%i\n", buffer[i]);
				//	}
				//	printf("\n");
				//	printf("sending to parse...");
				//	[rdpcore ParseMessage:buffer OfLength:length];
				[vnccore parseMessage:buffer ofLength:length];
			}
			//data = nil;
			//dataLength = 0;
			//dataIsInitialized = FALSE;
		}
			break;	
		case NSStreamEventErrorOccurred: 
		{
			NSLog(@"NSStreamError");
			[self.delegate networkErrorOccurred];
			[self disconnect];
			[iStream release];
			[oStream release];
		}
			break;
		case NSStreamEventOpenCompleted: {
			NSLog(@"NSStreamOpenCompleted");
			[self.delegate connectionDidFinishSuccessfully];
		}
	}
}



- (void) sendMessage: (const uint8_t*)str length:(int)length {
//	[self writeToServer:str length:length];
	[oStream write:str maxLength:length];
}

 
- (id) initWithVNCCore:(VNCCore*)vncCorePtr {
	[super init];
	dataIsInitialized = FALSE;
	dataLength = 0;
	self.vnccore = vncCorePtr;
	return self;
}


- (void) disconnect {
	[iStream close];
	[oStream close];
}

- (void) dealloc {
	[self disconnect];
	
	if ([iStream streamStatus] != NSStreamStatusClosed) { 
		[iStream close];
	}
	if ([oStream streamStatus] != NSStreamStatusClosed) {
		[oStream close];
	}
	
	[iStream release];
	[oStream release];
	
    [super dealloc];
}


@end
