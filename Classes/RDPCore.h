//
//  RDPCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunicator.h"
#import "RDPPrototypeViewController.h"

@class RDPPrototypeViewController;

@interface RDPCore : NSObject {
	
	NSString* serverIP;
	int serverPort;
	
	uint16_t SRCREF;
	uint16_t serverSRCREF;
	
	NetworkCommunicator* communicator;

	int status;
	
	RDPPrototypeViewController* viewController;
	
	int packetLength;
	uint8_t* packet;
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic) int serverPort;
@property (nonatomic, retain) RDPPrototypeViewController* viewController;
@property (nonatomic) int status;
@property (nonatomic, retain) NetworkCommunicator* communicator;
@property (nonatomic) uint8_t* packet;
@property (nonatomic) int packetLength;

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length;
-(int)InitConnecting;
-(int)CloseSession;
-(int)GenerateTPKTHeader:(uint8_t*) packet OfLength:(int) length;
-(int)GenerateMCSConnectInitialPDU;
-(bool)CheckTPKHeader:(uint8_t*) packet OfLength:(int) length;
-(id)initWithViewController:(RDPPrototypeViewController*)viewController;

@end
