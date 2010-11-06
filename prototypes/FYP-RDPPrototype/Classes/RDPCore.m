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
@synthesize severPort;

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length{
	
}

-(int)InitConnecting{
	
	int packetLength = 11;//in byte
	uint8_t* packet = malloc(sizeof(uint8_t * packetLength));
	
	//x224Crq started from byte 5 - 11
	
	packet[4] = 7;//LI feild, always 7 here
	packet[5] = 0xE0;//CR|CDT 1110 0000 for class 0
	
	packet[6] = 0;
	packet[7] = 0;//DST-REF 2 bytes 0
	
	SRCREF = 0;
	packet[8] = SRCREF/256;
	packet[9] = SRCREF%256;
	
	packet[10] = 0;//class option
	
	
}


-(int)GenerateTPKTHeader:(uint8_t*) packet OfLength (int) length{
	
	packet[0] = 0X03;//0000 0011
	packet[1] = 0;//Reserved
	
	packet[4] = length/256;
	packet[4] = length%256;
}


@end
