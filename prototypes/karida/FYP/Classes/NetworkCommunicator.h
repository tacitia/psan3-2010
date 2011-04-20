//
//  NetworkCommunicator.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//
//@class RDPCore;
@class VNCCore;
@class NetworkCommunicator;


@protocol NetworkCommunicatorDelegate <NSObject>
- (void)connectionDidFinishSuccessfully;
- (void)networkErrorOccurred;
@end


@interface NetworkCommunicator : NSObject <NSStreamDelegate> {
	NSInputStream* iStream;
	NSOutputStream* oStream;
	
	VNCCore* vnccore;
	id <NetworkCommunicatorDelegate> delegate;
}

@property (nonatomic, retain) VNCCore* vnccore;
@property (assign) id <NetworkCommunicatorDelegate> delegate;

- (void)sendMessage:(const uint8_t*)str length:(int)length;
- (void)disconnect;
- (id)initWithVNCCore:(VNCCore*)vncCorePtr;
- (void)connectToServerUsingStream:(NSString*)urlStr
							portNo:(uint)portNo;

@end