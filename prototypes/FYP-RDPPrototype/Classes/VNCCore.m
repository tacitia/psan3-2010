//
//  VNCCore.m
//  RDPPrototype
//
//  Created by LIU Haixiang on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "VNCCore.h"


@implementation VNCCore

@synthesize serverIP;
@synthesize serverPort;
@synthesize viewController;
@synthesize communicator;
@synthesize packet;
@synthesize packetLength;

-(int)initConnecting{
	communicator = [[NetworkCommunicator alloc] initWithVNCCore:self];
	[communicator setHost:serverIP port:serverPort];

	packetLength = 1;//in byte
	packet = malloc(sizeof(uint8_t) * packetLength);

	packet[0] = 0x01;

	[communicator sendMessage:packet length:13];

	return 1;
}

-(int)parseMessage:(uint8_t *)message ofLength:(int)length {
	return 1;
}

-(id)initWithViewController:(RDPPrototypeViewController*)viewControllerPtr {
	[super init];
	self.viewController = viewControllerPtr;
	self.communicator = nil;
	self.serverIP = nil;
	self.serverPort = 0;
	
	self.packetLength = 0;
	self.packet = NULL;
	
	return self;
}

@end
