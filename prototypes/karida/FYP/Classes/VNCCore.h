
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

struct PixelFormat {
	int bitPerPixel;
	int depth;
	int bigEndianFlag;
	int trueColorFlag;
	int redMax;
	int greenMax;
	int blueMax;
	int redShift;
	int greenShift;
	int blueShift;
};
struct RectPixel {
	int x;
	int y;
	int width;
	int height;
	int encoding;
};

@class RDPPrototypeViewController;

@interface VNCCore : NSObject {
	
	NSString* serverIP;
	int serverPort;
	RDPPrototypeViewController* viewController;
	NetworkCommunicator* communicator;
	int packetLength;
	uint8_t* packet;
	int status;
	int setupStatus;//used in serverinit msg
	int recievingStatus;
	
	uint8_t* serverVer;
	uint8_t* challange;
	//UIImage* display;
	unsigned char *displayArray;
	uint8_t* secTypes;
	int numOfSecTypes;
	int count;
	
	int framebufferWidth;
	int framebufferHeight;
	int numOfRects;
	int currentRectID;
	struct RectPixel currentRects;
	
	NSString* serverName;
	struct PixelFormat pixelFormat;
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic) int serverPort;
@property (nonatomic, retain) RDPPrototypeViewController* viewController;
@property (nonatomic, retain) NetworkCommunicator* communicator;
@property (nonatomic) int packetLength;
@property (nonatomic) uint8_t* packet;
@property (nonatomic) int status;
@property (nonatomic) uint8_t* serverVer;
//@property (nonatomic, retain) UIImage* display;
@property (nonatomic) unsigned char* displayArray;
@property (nonatomic) int numOfSecTypes;
@property (nonatomic) int count;
@property (nonatomic) uint8_t* challange;
@property (nonatomic) uint8_t* secTypes;
@property (nonatomic) int framebufferWidth;
@property (nonatomic) int framebufferHeight;
@property (nonatomic, retain) NSString* serverName;
@property (nonatomic) struct PixelFormat pixelFormat;
@property (nonatomic) int setupStatus;
@property (nonatomic) int recievingStatus;
@property (nonatomic) int numOfRects;
@property (nonatomic) struct RectPixel currentRects;
@property (nonatomic) int currentRectID;

-(int)initConnection;
-(id)initWithViewController:(RDPPrototypeViewController *)viewControllerPtr;
-(int)parseMessage:(uint8_t*)message ofLength:(int)length;
-(int)updateImage;

-(int)selectSecurityType:(uint8_t*)secTypes withNumOfOptions:(int)numOfSecTypes;

@end
