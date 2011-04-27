//
//  ConnectInfo.h
//  RDPPrototype
//
//  Created by Karida on 26/04/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ConnectInfo : UIViewController {
	//VNCCore* vnccoreInConnectInfo;
	
	UILabel * initIP;
	UILabel * initPort;
	
	IBOutlet UILabel * connectedIP;
	IBOutlet UILabel * connectedPort;
	
	IBOutlet UIButton * bkBtn;
}

//@property (nonatomic, retain) VNCCore* vnccoreInConnectInfo;
@property (nonatomic, retain) IBOutlet UILabel * connectedIP;
@property (nonatomic, retain) IBOutlet UILabel * connectedPort;
@property (nonatomic, retain) IBOutlet UIButton * bkBtn;

@property (nonatomic, retain) UILabel * initIP;
@property (nonatomic, retain) UILabel * initPort;



-(IBAction) bkBtnClicked: (id) sender;


@end
