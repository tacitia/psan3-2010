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
#import "MultiTouchViewController.h"

@interface RDPPrototypeViewController : UIViewController {
	
	@public
	
	IBOutlet UITextField *textMessage;
	IBOutlet UITextField *hostTextField;
	IBOutlet UITextField *portTextField;
	//IBOutlet UITextView *outputTextView;
	IBOutlet MultiTouchViewController *displayImage; 
	//RDPCore *rdpcore;
	VNCCore* vnccore;
}

@property (nonatomic, retain) UITextField* hostTextField;
@property (nonatomic, retain) UITextField* portTextField;
@property (nonatomic, retain) UITextField *textMessage;
@property (nonatomic, retain) UITextView *outputTextView;
@property (nonatomic, retain) MultiTouchViewController *displayImage; 
//@property (nonatomic, retain) RDPCore* rdpcore;
@property (nonatomic, retain) VNCCore* vnccore;

-(IBAction) sendMessage: (id) sender;
//-(IBAction) touchsMoved: (NSSet *)touches withEvent:(UIIEvent *)event;


@end

