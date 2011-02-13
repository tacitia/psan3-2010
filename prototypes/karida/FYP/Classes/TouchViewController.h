//
//  TouchViewController.h
//  RDPPrototype
//
//  Created by Karida on 18/01/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ConfigurationModal;

@interface TouchViewController : UIViewController <UIScrollViewDelegate> {
	
	//UITapGestureRecognizer *tapRecognizer;
	//UISwipeGestureRecognizer *swipeLeftRecognizer;
	//UILongPressGestureRecognizer * longPressRecognizer;
	//IBOutlet UIScrollView *imageScrollView;
	
	UIImage * image;
	UIImageView *imageView;
	ConfigurationModal * configurationModalInTouchViewController;
}

//@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
//@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;
//@property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;
//@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) ConfigurationModal * configurationModalInTouchViewController;

- (void)updateImage:(NSString *)imageNameString;
/*
 @interface MultiTouchViewController : UIImageView {
 
 }*/



@end