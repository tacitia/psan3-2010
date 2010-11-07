//
//  RDPCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunicator.h"
//#import "RDPPrototypeViewController.h"

@class RDPPrototypeViewController;

@interface RDPCore : NSObject {
	
	NSString* serverIP;
	int serverPort;
	
	uint16_t SRCREF;
	NetworkCommunicator* communicator;

	int status;
	
	RDPPrototypeViewController* viewController;
	
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic) int serverPort;
@property (nonatomic, retain) RDPPrototypeViewController* viewController;

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length;
-(int)InitConnecting;
-(int)CloseSession;
-(int)GenerateTPKTHeader:(uint8_t*) packet OfLength:(int) length;
-(int)CheckTPKHeader:(uint8_t*) packet;
-(id)initWithViewController:(RDPPrototypeViewController*)viewController;

@end
