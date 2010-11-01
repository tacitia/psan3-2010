//
//  CocoaMacServerAppDelegate.h
//  CocoaMacServer
//
//  Created by Guo Hua on 01/11/2010.
//  Copyright 2010 HKUST. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CocoaMacServerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
