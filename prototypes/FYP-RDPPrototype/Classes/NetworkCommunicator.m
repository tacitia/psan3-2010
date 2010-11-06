//
//  NetworkCommunicator.m
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import "NetworkCommunicator.h"
#import "NSStreamAdditions.h"


@implementation NetworkCommunicator


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


- (void) writeToServer:(const uint8_t*)buffer {
	[oStream write:buffer maxLength:strlen((char*)buffer)];
}


- (void)stream:(NSStream*)stream handleEvent:(NSStreamEvent)eventcode {
	
	switch(eventcode) {
		case NSStreamEventHasBytesAvailable:
		{
			if (data == nil) {
				data = [[NSMutableData alloc] init];
			}
			uint8_t buffer[1024];
			unsigned int length = 0;
			length = [(NSInputStream*)stream read:buffer maxLength:1024];
			if(length) {
				[data appendBytes:(const void*)buffer length:length];
				int bytesRead;
				bytesRead += length;
			} else {
				NSLog(@"No data.");
			}
			
			NSString *str = [[NSString alloc] initWithData:data
												  encoding:NSUTF8StringEncoding];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"From server"
															message:str
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			
			[alert show];
			[alert release];
			
			[str release];
			[data release];
			data = nil;
		}
			break;	
	}
}



- (void) sendMessage: (const uint8_t*)str {
	[self connectToServerUsingStream:self.host portNo:self.port];
	[self writeToServer:str];
}

- (void) setHost:(NSString*)host 
			port:(NSInteger)port {
	self.host = host;
	self.port = port;
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
