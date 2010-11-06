//
//  RDPPrototypeAppDelegate.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 06/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RDPPrototypeViewController;

@interface RDPPrototypeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RDPPrototypeViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RDPPrototypeViewController *viewController;

@end

