//
//  halo_worldAppDelegate.h
//  halo world
//
//  Created by LIU Haixiang on 18/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class halo_worldViewController;

@interface halo_worldAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    halo_worldViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet halo_worldViewController *viewController;

@end

