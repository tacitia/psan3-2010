//
//  RDPPrototypeViewController.h
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright HKUST 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkCommunicator.h"

@interface RDPPrototypeViewController : UIViewController {

	IBOutlet UITextField *textMessage;
	IBOutlet UITextField *hostTextField;
	IBOutlet UITextField *portTextField;
	NetworkCommunicator *networkCommunicator;

}

@property (nonatomic, retain) UITextField* hostTextField;
@property (nonatomic, retain) UITextField* portTextField;
@property (nonatomic, retain) UITextField *textMessage;
@property (nonatomic, retain) NetworkCommunicator *networkCommunicator;

-(IBAction) sendMessage: (id) sender;

@end

