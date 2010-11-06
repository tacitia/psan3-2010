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
	NetworkCommunicator *networkCommunicator;

}

@property (nonatomic, retain) UITextField *textMessage;

-(IBAction) sendMessage: (id) sender;

@end

