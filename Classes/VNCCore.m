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
@synthesize status;
@synthesize serverVer;

-(int)initConnection{
	
	[self updateImage];
	
	communicator = [[NetworkCommunicator alloc] initWithVNCCore:self];
	[communicator setHost:serverIP port:serverPort];

	packetLength = 1;//in byte
	packet = malloc(sizeof(uint8_t) * packetLength);
	packet[0] = 0x01;

	[communicator sendMessage:packet length:packetLength];
	self.status = 1;
	
	return 1;
}

-(int)parseMessage:(uint8_t *)message ofLength:(int)length {
	switch (status) {
		case 1:	{
			serverVer = malloc(sizeof(uint8_t) * 8);
			memcpy(serverVer, message+4*8, 8);
			uint8_t* reply = malloc(sizeof(uint8_t) * 12);
			memcpy(reply, message, 12);
			[communicator sendMessage:reply length:12];
			status = 2;
		}
		break;
		case 2: {
			int numOfSecTypes = message[0];
			// connection failed
			if (numOfSecTypes == 0) {
				return -1;
			}
			else {
				uint8_t* secTypes = malloc(sizeof(uint8_t) * numOfSecTypes);
				memcpy(secTypes, message+1*8, numOfSecTypes);
				int selectedSec = [self selectSecurityType:secTypes withNumOfOptions:numOfSecTypes];
				uint8_t* reply = malloc(sizeof(uint8_t) * 1);
				reply[0] = selectedSec;
				[communicator sendMessage:reply length:1];
			}
			status = 3;
		}
		break;
		case 3: {
			if (message[3] == 0) {
				uint8_t* reply = malloc(sizeof(uint8_t) * 1);
				// the server should try to share the desktop by leaving other clients connected
				reply[0] = 1;
				[communicator sendMessage:reply length:1];
				status = 4;
			}
			else {
				return -1;
			}
		}
		default:
			break;
	}
	
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
	self.status = 0;
	
	
	return self;
}

-(int)selectSecurityType:(uint8_t*)secTypes withNumOfOptions:(int)numOfSecTypes {
	return 1;
}

-(int)updateImage{
	printf("lala");
	display = [UIImage imageNamed:@"Microsoft_Silverlight.png"];
	[viewController.displayImage setImage:display];
	printf("hah");
	return 1;
}

@end
