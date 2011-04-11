//
//  ConfigurationModal.h
//  RDPPrototype
//
//  Created by Karida on 12/02/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpPage.h"


@interface ConfigurationModal : UIViewController {

	/*
	  Boolean indicating whether the gesture is activated.
	  Default should all be activated
	 */
	//Double finger tap at once == mouse right click
	Boolean twoFingerTapActivated;
	
	//Long Press to open the alert window for closing
	Boolean longPressActivated;
	
	Boolean panRecognizerActivated;	
	
	Boolean threeFingerPanRecognizerActivated; 
	
	IBOutlet UITableView *ConfigTable;
	
	NSMutableArray *ConfigArray;
	
	HelpPage *helpView;
	
}

@property (nonatomic, retain) IBOutlet UITableView *ConfigTable;
@property (nonatomic, retain) HelpPage *helpView;

-(IBAction) cancellConfiguration: (id) sender;
-(IBAction) saveConfiguration: (id) sender;

@end
