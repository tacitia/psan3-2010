//
//  RDPCore.m
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RDPCore.h"


@implementation RDPCore

@synthesize serverIP;
@synthesize serverPort;
@synthesize viewController;
@synthesize status;
@synthesize communicator;

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length{
	//printf("dada");
	//viewController->outputTextView.text = @"1234";
	if(status == 255){
		//connection has already setted up 
	}else{
		switch (status) {
			case 1:
				if([self CheckTPKHeader:message OfLength:length]){
					//-----check X.224 CC-----//
					if(message[4] == 6 &&//LI feild, always 6 here
					   message[5] == 0xD0 &&//CC|CDT 1101 0000 for class 0
					   
					   message[6] == 0 &&
					   message[7] == 0 &&//DST-REF 2 bytes 0
					   
					   message[10] == 0)//class option
					{
						serverSRCREF = message[8] * 256 + message[9];
						printf("checked/n");
						
					}else {
						return 0;
					}
					//-----check X.224 CC FINISHED-----//
					//-----Generate
				}else{
					return 0;
				}
				break;
			default:
				break;
		}
	}
	return 1;
}

-(int)InitConnecting{
	
	communicator = [[NetworkCommunicator alloc] initWithRDPCore:self];
	[communicator setHost:serverIP port:serverPort];
	
	
	//----X.224 connection request packet----//
	int packetLength = 11;//in byte
	uint8_t* packet = malloc(sizeof(uint8_t) * packetLength);
	
	//x224Crq started from byte 5 - 11
	
	packet[4] = 6;//LI feild, always 8 here
	packet[5] = 0xE0;//CR|CDT 1110 0000 for class 0
	
	packet[6] = 0;
	packet[7] = 0;//DST-REF 2 bytes 0
	
	SRCREF = 0;
	packet[8] = SRCREF/256;
	packet[9] = SRCREF%256;
	
	packet[10] = 0;//class option
	
	[self GenerateTPKTHeader:packet OfLength:11];

/*	printf("%i\n",packet[0]);
	printf("%i\n",packet[1]);
	printf("%i\n",packet[2]);
	printf("%i\n",packet[3]);
 */
	
	[communicator sendMessage:packet length:11];
	//----X.224 connection request packet finish----//
	
	status = 1;//startConnecting
	
	return 1;
}


-(int)GenerateTPKTHeader:(uint8_t*) packet OfLength:(int) length{
	
	packet[0] = 0X03;//0000 0011
	packet[1] = 0;//Reserved
	
	packet[2] = length >> 8;
	packet[3] = length%256;
	
	return 1;
}

-(bool)CheckTPKHeader:(uint8_t*) packet OfLength:(int) length{
	return (packet[0] == 0x03 && packet[2] == length >> 8 && packet[3] == length%256);
}

-(id)initWithViewController:(RDPPrototypeViewController*)viewControllerPtr {
	[super init];
	self.viewController = viewControllerPtr;
	self.status = 0;
	self.communicator = nil;
	self.serverIP = nil;
	self.serverPort = 0;
	
	return self;
}



@end
