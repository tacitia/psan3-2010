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
	
	IBOutlet UITableView *ConfigTable;
	
	NSMutableArray *ConfigArray;
	
	HelpPage *helpView;

	/*
	  Boolean indicating whether the gesture is activated.
	  Default should all be activated
	 */
	@public
	//Double finger tap at once == mouse right click
	Boolean twoFingerTapActivated;
	
	//Long Press to open the alert window for closing
	Boolean longPressActivated;
	
	//Not used currently
	Boolean panRecognizerActivated;	
	
	Boolean threeFingerPanLeftRecognizerActivated; 
	
	Boolean threeFingerPanUpRecognizerActivated;
	
	Boolean threeFingerPanDownRecognizerActivated;
	
	//Temporary Boolean Variables to store temporary user selections
	Boolean TemptwoFingerTapActivated;
	Boolean TemplongPressActivated;
	Boolean TempthreeFingerPanLeftRecognizerActivated; 
	Boolean TempthreeFingerPanUpRecognizerActivated;
	Boolean TempthreeFingerPanDownRecognizerActivated;
	
		
}

@property (nonatomic, retain) IBOutlet UITableView *ConfigTable;
@property (nonatomic, retain) HelpPage *helpView;

-(IBAction) cancellConfiguration: (id) sender;
-(IBAction) saveConfiguration: (id) sender;

@end
