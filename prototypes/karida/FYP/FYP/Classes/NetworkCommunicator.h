//
//  NetworkCommunicator.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//
//@class RDPCore;
@class VNCCore;


@interface NetworkCommunicator : NSObject {

	NSString* host;
	NSInteger port;
	
//	NSMutableData* data;
	
	NSInputStream* iStream;
	NSOutputStream* oStream;
	
//  RDPCore* rdpcore;
	VNCCore* vnccore;
}

@property (nonatomic, retain) NSString* host;
@property (nonatomic) NSInteger port;
//@property (nonatomic, retain) RDPCore* rdpcore;
@property (nonatomic, retain) VNCCore* vnccore;

- (BOOL)setHost:(NSString*)host
		   port:(NSInteger)port;
- (void)sendMessage:(const uint8_t*)str length:(int)length;

//- (id)initWithRDPCore:(RDPCore*)rdpCorePtr;
- (id)initWithVNCCore:(VNCCore*)vncCorePtr;

@end
