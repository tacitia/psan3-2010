//
//  ConfigurationModal.h
//  RDPPrototype
//
//  Created by Karida on 12/02/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelpPage.h"
#import "VNCCore.h"
#import "ConnectInfo.h"

@interface ConfigurationModal : UIViewController {
	
	IBOutlet UITableView *ConfigTable;
	
	NSMutableArray *ConfigArray;
	
	HelpPage *helpView;
	
	ConnectInfo *info;

	/*
	  Boolean indicating whether the gesture is activated.
	  Default should all be activated
	 */
	@public
	
	UISwitch *switchInCell1;
	UISwitch *switchInCell2;
	UISwitch *switchInCell3;
	UISwitch *switchInCell4; 
	UISwitch *switchInCell5;
    NSArray *switchArray;    
	
	//bit 0-4 stores whether the ith switch is on or off
	int activated;
	int tempActivated;
	
	VNCCore* vnccoreInConfig;
	
	/*
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
	*/
}
@property (nonatomic, retain) VNCCore* vnccoreInConfig;

@property (nonatomic, retain) IBOutlet UITableView *ConfigTable;
@property (nonatomic, retain) HelpPage *helpView;
@property (nonatomic, retain) ConnectInfo *info;

@property (nonatomic, retain) UISwitch *switchInCell1;
@property (nonatomic, retain) UISwitch *switchInCell2;
@property (nonatomic, retain) UISwitch *switchInCell3;
@property (nonatomic, retain) UISwitch *switchInCell4;
@property (nonatomic, retain) UISwitch *switchInCell5;

@property (nonatomic, retain) NSArray *switchArray;    

@property (nonatomic, retain) NSArray *activatedArray;
@property (nonatomic, retain) NSArray *tempActivatedArray;

-(IBAction) cancellConfiguration: (id) sender;
-(IBAction) saveConfiguration: (id) sender;

-(void)setVncInfo:(VNCCore *) vnc;

@end
