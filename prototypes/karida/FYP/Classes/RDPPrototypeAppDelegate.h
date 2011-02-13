//
//  RDPPrototypeAppDelegate.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright HKUST 2010. All rights reserved.
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

