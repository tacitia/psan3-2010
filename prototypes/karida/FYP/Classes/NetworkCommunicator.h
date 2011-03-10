//
//  NetworkCommunicator.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//
//@class RDPCore;
@class VNCCore;


@interface NetworkCommunicator : NSObject <NSStreamDelegate> {
	
	NSInputStream* iStream;
	NSOutputStream* oStream;
	
	VNCCore* vnccore;
}

@property (nonatomic, retain) VNCCore* vnccore;

- (void)sendMessage:(const uint8_t*)str length:(int)length;

- (id)initWithVNCCore:(VNCCore*)vncCorePtr;
- (void)connectToServerUsingStream:(NSString*)urlStr
							portNo:(uint)portNo;

@end