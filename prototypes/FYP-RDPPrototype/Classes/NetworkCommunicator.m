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


NSMutableData* data;

NSInputStream* iStream;
NSOutputStream* oStream;


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

- (void) sendMessage: (uint8_t*)str {
	[self connectToServerUsingStream:@"localhost" portNo:9999];
	[self writeToServer:str];
}

@end
