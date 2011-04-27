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
#import "saveGesture.h"

@class ConfigurationModal;

@interface TouchViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate> {
	
	
	UIImage * image;
	UIImageView *imageView;
	UIScrollView * imageScrollView;
	ConfigurationModal * configurationModalInTouchViewController;
	
	//for keyboard input
	UITextField * inputText;
	
	//for Shortcuts Keyboard
	UIView * shortCutView;
	Boolean shortCutOut;
	
	VNCCore* vnccore;
	
	//Boolean to indicate whether the keyboard is out
	Boolean keyboardIsOut;
	
	//whether the screen is locked. default is no
	Boolean screenLocked;
	
	/*
	 Optional Gesture references
	 */
	//Double finger tap at once == mouse right click
	UITapGestureRecognizer *twoFingerTap;
	
	//Long Press to open the alert window for closing
	UILongPressGestureRecognizer * longPress;
	
	UIPanGestureRecognizer *panRecognizer;	
	
	UIPanGestureRecognizer *threeFingerPanRecognizer;  //used for minimize, maximize, switch window
	NSInteger countThreeFingerPan;  //Count the number of three finger pan recognized, and send keyboard input alt+shift+tab
	
	//Start and End positions for pan gestures
	CGPoint startLocation;
	CGPoint endLocation;
	
	//Previous and current position used for two finger pan
	CGPoint prevLocation;
	CGPoint curLocation;
	
	saveGesture * saveFirstPoint;
	
	//public NSString * connectedIP;
	//public NSString * connectedPort;
}



@property (nonatomic, retain) IBOutlet UIScrollView *imageScrollView;

@property (nonatomic, retain) IBOutlet UITextField * inputText;

@property (nonatomic, retain) IBOutlet UIView * shortCutView;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) ConfigurationModal * configurationModalInTouchViewController;

@property (nonatomic, retain) VNCCore* vnccore;

@property (nonatomic, retain) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, retain) UIPanGestureRecognizer *threeFingerPanRecognizer;
@property (nonatomic, retain) UITapGestureRecognizer *twoFingerTap;
@property (nonatomic, retain) UILongPressGestureRecognizer * longPress;

@property (nonatomic, retain) saveGesture * saveFirstPoint;
//@property (nonatomic, retain) NSString * connectedIP;
//@property (nonatomic, retain) NSString * connectedPort;

- (void)updateImage:(UIImage *)myimage;

- (IBAction)textFieldDone:(id)sender; 

- (IBAction)editText:(id)sender; 

- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)showShortCut:(id) sender;

- (IBAction)configGestures:(id) sender;

- (IBAction)lockScreen:(id)sender;

- (IBAction) sendCtrlC:(id)sender;
- (IBAction) sendCtrlV:(id)sender;

- (IBAction) sendTaskManager:(id)sender;

- (IBAction) sendCtrlF4:(id)sender;
- (IBAction) sendCtrlSpace:(id)sender;
- (IBAction) sendTab:(id)sender;
- (IBAction) sendAltTab:(id)sender;
- (IBAction) sendAltF4:(id)sender;
- (IBAction) sendEsc:(id)sender;
- (IBAction) sendEnter:(id)sender;

- (IBAction) sendLeft:(id)sender;
- (IBAction) sendRight:(id)sender;
- (IBAction) sendUp:(id)sender;
- (IBAction) sendDown:(id)sender;

- (IBAction) logOut:(id)sender;

- (void)endConnection;


/*
 @interface MultiTouchViewController : UIImageView {
 
 }*/



@end