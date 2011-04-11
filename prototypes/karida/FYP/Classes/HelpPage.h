//
//  HelpPage.h
//  RDPPrototype
//
//  Created by Karida on 11/04/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpPage : UIViewController {
	
	UIImageView *helpImage;
}

@property (nonatomic, retain) IBOutlet UIImageView *helpImage;

-(IBAction) backButtonClicked : (id) sender;

@end
