//
//  MultiTouchController.h
//  RDPPrototype
//
//  Created by LIU Haixiang on 03/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MultiTouchViewController : UIViewController <UIGestureRecognizerDelegate> {
	
	UITapGestureRecognizer *tapRecognizer;
	UISwipeGestureRecognizer *swipeLeftRecognizer;
	
	UIImageView *imageView;
}

@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;

@property (nonatomic, retain) UIImageView *imageView;

/*
@interface MultiTouchViewController : UIImageView {

}*/



@end
