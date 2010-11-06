//
//  RDPCore.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RDPCore : NSObject {
	
	NSstring serverIP;
	int serverPort;
	uint16_t SRCREF;
	
}

-(int)ParseMessage:(uint8_t*)message OfLength:(int) length;
-(int)InitConnecting;
-(int)CloseSession;
-(int)GenerateTPKTHeader:(uint8_t*) packet OfLength (int) length;

@end