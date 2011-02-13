//
//  NSStreamAdditions.h
//  Network
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//


@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString*)hostName
						 port:(NSInteger)port
				  inputStream:(NSInputStream**)inputStreamPtr
				 outputStream:(NSOutputStream**)outputStreamPtr;

@end