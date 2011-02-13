//
//  RDPPrototypeViewController.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright HKUST 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkCommunicator.h"
#import "RDPCore.h"
#import "VNCCore.h"
//#import "MultiTouchViewController.h"
//#import "TouchViewController.h"
@class TouchViewController;

@interface RDPPrototypeViewController : UIViewController {
	
	@public
	
	IBOutlet UITextField *textMessage;
	IBOutlet UITextField *hostTextField;
	IBOutlet UITextField *portTextField;
//	IBOutlet MultiTouchViewController *displayImage; 
	
	BOOL isShowingDesktop;
	TouchViewController *touchViewController;

	VNCCore* vnccore;
}

@property (nonatomic, retain) UITextField* hostTextField;
@property (nonatomic, retain) UITextField* portTextField;
@property (nonatomic, retain) UITextField *textMessage;
@property (nonatomic, retain) UITextView *outputTextView;
//@property (nonatomic, retain) MultiTouchViewController *displayImage; 
@property (nonatomic, retain) VNCCore* vnccore;
@property (nonatomic, retain) TouchViewController *touchViewController;


-(IBAction) sendMessage: (id) sender;

@end

