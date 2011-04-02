//
//  TouchViewController.h
//  RDPPrototype
//
//  Created by Karida on 18/01/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VNCCore.h"

@class ConfigurationModal;

@interface TouchViewController : UIViewController <UIScrollViewDelegate> {
	
	//UITapGestureRecognizer *tapRecognizer;
	//UISwipeGestureRecognizer *swipeLeftRecognizer;
	//UILongPressGestureRecognizer * longPressRecognizer;
	//IBOutlet UIScrollView *imageScrollView;
	
	UIImage * image;
	UIImageView *imageView;
	UIScrollView * imageScrollView;
	ConfigurationModal * configurationModalInTouchViewController;
	
	//for keyboard input, normally hidden
	UITextField * inputText;
	UIButton * doneButton;
	UIView * inputTextView;
	
	//for lock/unlock the screen
	UIBarButtonItem * lockUnlockScreenBtn;
	Boolean screenLocked;
	
	VNCCore* vnccore;
	
	//Boolean to indicate whether the keyboard is out
	Boolean keyboardIsOut;
	
	//Gesture references
	UIPanGestureRecognizer *panRecognizer;	//enabled when the screen is locked
	
	NSInteger countThreeFingerPan;  //Count the number of three finger pan recognized, and send keyboard input alt+shift+tab
	UIPanGestureRecognizer *threeFingerPanRecognizer;  //used for minimize, maximize, switch window
	
	//Start and End positions for pan gestures
	CGPoint startLocation;
	CGPoint endLocation;
	
}

//@property (nonatomic, retain) UITapGestureRecognizer *tapRecognizer;
//@property (nonatomic, retain) UISwipeGestureRecognizer *swipeLeftRecognizer;
//@property (nonatomic, retain) UILongPressGestureRecognizer *longPressRecognizer;

@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) IBOutlet UITextField * inputText;
@property (nonatomic, retain) IBOutlet UIButton * doneButton;
@property (nonatomic, retain) IBOutlet UIView * inputTextView;

@property (nonatomic, retain) IBOutlet UIBarButtonItem * lockUnlockScreenBtn;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) ConfigurationModal * configurationModalInTouchViewController;

@property (nonatomic, retain) VNCCore* vnccore;

@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;
//@property (nonatomic, retain) NSInteger countThreeFingerPan;
@property (nonatomic, retain) UIPanGestureRecognizer *threeFingerPanRecognizer;

- (void)updateImage:(UIImage *)myimage;
- (IBAction)textFieldDone:(id)sender; 

- (IBAction)editText:(id)sender; 
- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)lockUnlockScreenFunc: (id) sender;


/*
 @interface MultiTouchViewController : UIImageView {
 
 }*/



@end