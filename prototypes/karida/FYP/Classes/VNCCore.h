
//
//  VNCCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 28/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCommunicator.h"
#import "RDPPrototypeViewController.h"

@class RDPPrototypeViewController;

@interface VNCCore : NSObject {

	NSString* serverIP;
	int serverPort;
	RDPPrototypeViewController* viewController;
	NetworkCommunicator* communicator;
	int packetLength;
	uint8_t* packet;
	int status;
	uint8_t* serverVer;
	UIImage *display;
	
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic) int serverPort;
@property (nonatomic, retain) RDPPrototypeViewController* viewController;
@property (nonatomic, retain) NetworkCommunicator* communicator;
@property (nonatomic) int packetLength;
@property (nonatomic) uint8_t* packet;
@property (nonatomic) int status;
@property (nonatomic) uint8_t* serverVer;
@property (nonatomic) UIImage* display;

-(int)initConnection;
-(id)initWithViewController:(RDPPrototypeViewController *)viewControllerPtr;
-(int)parseMessage:(uint8_t*)message ofLength:(int)length;
-(int)updateImage;

@end
