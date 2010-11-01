//
//  SCMTestAppDelegate.h
//  SCMTest
//
//  Created by Guo Hua on 01/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SCMTestAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	NSUInteger *number; // testing SCM
}

@property (assign) IBOutlet NSWindow *window;

@end
