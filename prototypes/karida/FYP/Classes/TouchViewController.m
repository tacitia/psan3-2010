    //
//  TouchViewController.m
//  RDPPrototype
//
//  Created by Karida on 18/01/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "TouchViewController.h"
#import "ConfigurationModal.h"

#define ZOOM_STEP 1.5  

@interface TouchViewController (UtilityMethods)  
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;  
@end  

@implementation TouchViewController
@synthesize image, imageView, configurationModalInTouchViewController, imageScrollView, inputText, vnccore,
panRecognizer, threeFingerPanRecognizer, twoFingerTap, longPress, shortCutView;


 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 
 
 }
 return self;
 }


- (void)viewDidLoad {
	[super viewDidLoad];
	
	imageView = [[UIImageView alloc] initWithImage:image]; 
	imageView.userInteractionEnabled = YES;  
	
	CGRect imageFrame = CGRectMake(0,0,image.size.width, image.size.height);
	[imageView setFrame:imageFrame];
	//imageView.clipsToBounds = YES;
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	[imageScrollView setBouncesZoom:YES];
	[imageScrollView setDelegate:self];
		
	[imageScrollView setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
	[imageScrollView addSubview:imageView];	
	
	imageScrollView.scrollEnabled = FALSE; 
	
	/*
	   add gesture recognizers to the image view 
	*/
	
	//One finger single tap to left-click
	//This gesture is not optional 
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[imageView addGestureRecognizer:singleTap]; 
	 
	
	//One finger double tap 
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	[imageView addGestureRecognizer:doubleTap]; 
	[doubleTap setNumberOfTapsRequired:2];   
	
	[singleTap requireGestureRecognizerToFail:doubleTap];
	
	[singleTap release];
	[doubleTap release]; 
	
	//Single Pan
	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[imageView addGestureRecognizer:panRecognizer];
	
	/*
	  Following gestures are optional
	 */
	
	//two finger single tap to right-click
	twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];  
	[twoFingerTap setNumberOfTouchesRequired:2];  
	[imageView addGestureRecognizer:twoFingerTap];  
	
	//long press
	//display a window for exiting the app.
	longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];  
	[longPress setMinimumPressDuration:1];
	[imageView addGestureRecognizer:longPress];
	
	threeFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerPan:)];
	[threeFingerPanRecognizer setMinimumNumberOfTouches:3];
	[threeFingerPanRecognizer setMaximumNumberOfTouches:3];
	[imageView addGestureRecognizer:threeFingerPanRecognizer];
	
	//[panRecognizer requireGestureRecognizerToFail:threeFingerPanRecognizer];
			
	// calculate minimum scale to perfectly fit image width, and begin at that scale  
	float minimumScale = [imageScrollView frame].size.width  / [imageScrollView frame].size.width;  
	[imageScrollView setMaximumZoomScale:5.0];
	[imageScrollView setMinimumZoomScale:minimumScale];
	[imageScrollView setZoomScale:minimumScale];
	
	
	//Default the keyboard should not present
	keyboardIsOut = FALSE;
	
	//Default shortCutOut = false
	shortCutOut = FALSE;
	self.shortCutView.hidden = TRUE;
	
	//Default screen is not locked
	screenLocked = FALSE;
	
	//Notification sent when the keyboard resigns
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
	
	//Configuration page set up
	configurationModalInTouchViewController = [[ConfigurationModal alloc] initWithNibName:@"ConfigurationModal" bundle:Nil];
	
}

- (void)updateImage:(UIImage *)myimage {
//	NSLog(@"update image!");
	image = myimage;
	imageView.image = image;
	[imageView setImage:image];
	[imageScrollView setNeedsDisplay];
	[self.view setNeedsDisplay];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {	
	keyboardIsOut = TRUE;
	NSLog(@"called textfield begin editing");
	//self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y - 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
	[self.inputText becomeFirstResponder];
}

- (IBAction)doneButtonPressed:(id)sender{
	
	/*
	  send msg to server
	  content is inputText.text
	 */
	
	//self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y + 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);

	keyboardIsOut = FALSE;
	
	//[sender resignFirstResponder];
	[self.inputText resignFirstResponder];
	NSLog(@"done button dragged!!!");
	NSLog(@"%@", self.inputText.text); //This line has strange behavior - it sometimes output null sring
	
	[vnccore putTextIntoCutBuffer:self.inputText.text]; 
	
	[self.inputText setText:@""];	
}

-(void)keyboardWillDisappear:(NSNotification *) notification {
	NSLog(@"keyboard disappear");
	
	if (keyboardIsOut == TRUE) {
		
		keyboardIsOut = FALSE;

	}
	 
	
}


//Functions for locking/unlocking the scree
/*
- (IBAction)lockUnlockScreenFunc: (id) sender{
	
	if (screenLocked == FALSE) {
		NSLog(@"Lock the Screen");
		[lockUnlockScreenBtn setTitle:@"Unlock Screen"]; 
		screenLocked = TRUE;
		
		//disable scroll view scrolling
		imageScrollView.scrollEnabled = FALSE;
		
		//Add single finger double tap gesture
		//[imageView addGestureRecognizer:oneFingerDoubleTap];  
		
		//Add Pan gesture
		//[imageView addGestureRecognizer:oneFingerDoubleTap];
		[imageView addGestureRecognizer:panRecognizer];
		
	}
	else {
		NSLog(@"Unlock the Screen");
		[lockUnlockScreenBtn setTitle:@"Lock Screen"];
		screenLocked = FALSE;
		
		//enable scroll view scrolling 
		//treat the screen as image
		imageScrollView.scrollEnabled = YES;
		
		//Remove Pan gesture
		//[imageView removeGestureRecognizer:oneFingerDoubleTap];
		[imageView removeGestureRecognizer:panRecognizer];
	}
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    //return YES;
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	
	//self.tapRecognizer = nil;
	//self.swipeLeftRecognizer = nil;
	self.imageView = nil;
	self.image = nil;
	self.imageScrollView = nil;
	self.configurationModalInTouchViewController = nil;
	//self.imageScrollView = nil; 
	
}

#pragma mark UIScrollViewDelegate methods  

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView { 
	return imageView;
}  

#pragma mark TapDetectingImageViewDelegate methods  

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {  
	// single tap does nothing for now  

	NSLog(@"SINGLE TAP!");
	
	/*
	inputText = [[UITextField alloc] initWithFrame:CGRectMake(25, 25, 400, 50)];
	[inputText becomeFirstResponder];
	//inputText.delegate = self.inputText;
	inputText.returnKeyType = UIReturnKeyDone;
	inputText.autocapitalizationType = UITextAutocapitalizationTypeWords;
	[inputText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];     
	[imageView addSubview:inputText];
	//[imageScrollView setNeedsDisplay];
	//[self.view setNeedsDisplay];
	 */

//	CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
//	CGPoint adjustedTouchLocation = CGPointMake(touchLocation.x * imageView.frame.size.width / imageScrollView.frame.size.width,
//												touchLocation.y * imageView.frame.size.height / imageScrollView.frame.size.height);
	
	CGPoint touchLocation = [gestureRecognizer locationInView:imageView];
	
	// x alwas equals zero?
	printf("x = %f and y = %f",touchLocation.x, touchLocation.y);
	
	[vnccore sendLeftClickEventAtPosition:touchLocation];
	/*
	test for changing display image
	 */
	//[self updateImage:@"tap.png"];
	
	//[self viewDidLoad];
	
	//[self.view addSubview:touchViewController.view];	
	
	/*test end*/
}  

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	NSLog(@"Double Tap!");
	
	/*
	// single finger double tap is to zoom in  
	float newScale = [imageScrollView zoomScale] * ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	
	[imageScrollView zoomToRect:zoomRect animated:YES];  
	 */
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
	// two-finger tap zooms out  
	if (configurationModalInTouchViewController != NULL) {
		
		int temp = (configurationModalInTouchViewController->activated) >> 0;
		if (temp % 2 == 1) {
			//it is activated
			NSLog(@"Right Click!");
			
			[vnccore sendRightClickEventAtPosition:[gestureRecognizer locationInView:self.imageView]];
		}
		else {
			//it is deactivated
			NSLog(@"Right Click Turned Off!");
		}
		
		/*
		Boolean s = configurationModalInTouchViewController->twoFingerTapActivated;
		if (s == TRUE) {
			NSLog(@"Right Click!");
		}
		else {
			NSLog(@"Right Click Turned Off!");
		 */
	}
	
	/*
	float newScale = [imageScrollView zoomScale] / ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[imageScrollView zoomToRect:zoomRect animated:YES];  
	 */
}  

-(void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
	//NSLog(@"Single Finger Pan!");
	
	//Find the start and end points
	//CGPoint start;
	//CGPoint end;
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		
        startLocation = [gestureRecognizer locationInView:self.imageView];
		NSLog(@"start is : ( %f , %f )", startLocation.x, startLocation.y);
		
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		
		endLocation = [gestureRecognizer locationInView:self.imageView];
        NSLog(@"end is : ( %f , %f )", endLocation.x, endLocation.y);
        
    }
	[vnccore sendMouseDragEventFromPosition:startLocation toPosition:endLocation];
}

-(void)handleThreeFingerPan:(UIPanGestureRecognizer *)gestureRecognizer {
	//For minimize&maximize window, and switch between different windows function
	//NSLog(@"Three Finger Pan!");
	//NSLog(@"Count = %d", countThreeFingerPan);
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {		
		startLocation = [gestureRecognizer locationInView:self.imageView];
		NSLog(@"start for three fingers is : ( %f , %f )", startLocation.x, startLocation.y);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {		
		endLocation = [gestureRecognizer locationInView:self.imageView];
        NSLog(@"end for three fingers is : ( %f , %f )", endLocation.x, endLocation.y);
		
		//Identify whether it is up, down or left pan
		double diffX = fabs(startLocation.x - endLocation.x);
		double diffY = fabs(startLocation.y - endLocation.y);
		
		//NSLog(@"diff X = %f and diff Y = %f", diffX, diffY);
		
		if (diffX > diffY) {
			//It is left pan
			
			if (configurationModalInTouchViewController != NULL) {
				
				int temp = (configurationModalInTouchViewController->activated) >> 3;
				if (temp % 2 == 1) {
					//it is activated
					NSLog(@"Left Pan!");
				
				}
				else {
					//it is deactivated
					NSLog(@"Left Pan Turned Off!");
				}
				
				/*
				Boolean s = configurationModalInTouchViewController->threeFingerPanLeftRecognizerActivated;
				if (s == TRUE) {
					NSLog(@"Left Pan!");
				}
				else {
					NSLog(@"Left Pan Turned Off!");
				}
				 */
			}
		}
		else {
			if (startLocation.y > endLocation.y) {
				//it is an up pan
				//Maximize the current window
				if (configurationModalInTouchViewController != NULL) {
					
					int temp = (configurationModalInTouchViewController->activated) >> 1;
					if (temp % 2 == 1) {
						//it is activated
						NSLog(@"Up Pan!");
						[vnccore maximizeCurrentActiveWindow];
					}
					else {
						//it is deactivated
						NSLog(@"Up Pan Turned Off!");
					}
					
					/*
					Boolean s = configurationModalInTouchViewController->threeFingerPanUpRecognizerActivated;
					if (s == TRUE) {
						NSLog(@"Up pan!");
					}
					else {
						NSLog(@"Up pan Turned Off!");
					}
					 */
				}
			}
			else {
				//it is a down pan
				//Minimize the current window
				if (configurationModalInTouchViewController != NULL) {
					
					int temp = (configurationModalInTouchViewController->activated) >> 2;
					if (temp % 2 == 1) {
						//it is activated
						NSLog(@"Down Pan!");
						[vnccore minimizeCurrentActiveWindow];
					}
					else {
						//it is deactivated
						NSLog(@"Down Pan Turned Off!");
					}
					/*
					Boolean s = configurationModalInTouchViewController->threeFingerPanDownRecognizerActivated;
					if (s == TRUE) {
						NSLog(@"Down pan!");
					}
					else {
						NSLog(@"Down pan Turned Off!");
					}
					 */
				}
			}
		}
	}
	else {
		//Count add one to itself. When count up to 30, send alt+shift+tab to server
		countThreeFingerPan++;
		if (countThreeFingerPan >30) {
			//Send tab to server while alt+shift is pressed down
			NSLog(@"count up to 30!!");
			
			
			//Clear the count
			countThreeFingerPan = 0;
		}
	}
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {

	if (gestureRecognizer.state == UIGestureRecognizerStateEnded ) {
		//Function invoked again but do nothing
	}
	else{
		
		if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
			
			if (configurationModalInTouchViewController != NULL) {
				
				int temp = (configurationModalInTouchViewController->activated) >> 4;
				if (temp % 2 == 1) {
					//it is activated
					NSLog(@"Long Press!");
					UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Caution!"
																	 message:@"Do you want to close the current window?"
																	delegate:self 
														   cancelButtonTitle:@"Cancel" 
														   otherButtonTitles:nil];
					[alert addButtonWithTitle:@"Close"];
					[alert show];
					[alert release];
				}
				else {
					//it is deactivated
					NSLog(@"Long Press Turned Off!");
				}
				
				/*
				Boolean s = configurationModalInTouchViewController->longPressActivated;
				if (s == TRUE) {
					NSLog(@"Long Press!");
					UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Caution!"
															 message:@"Do you want to close the current window?"
															delegate:self 
												   cancelButtonTitle:@"Cancel" 
												   otherButtonTitles:nil];
					[alert addButtonWithTitle:@"Close"];
					[alert show];
					[alert release];
					
				}
				else {
					NSLog(@"Long press Turned Off!");
				}
				 */
			}
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (buttonIndex == 0)
	{
		NSLog(@"Cancel Button");
	}
	else
	{
		NSLog(@"Close Current Window!");
	}
}

/*
 IB Actions
*/
- (IBAction)showShortCut:(id) sender{
		
	if (shortCutOut == FALSE) {
		self.shortCutView.hidden = FALSE;
		[self.view addSubview:self.shortCutView];
		shortCutOut = TRUE;
	}
	else {
		self.shortCutView.hidden = TRUE;
		[self.shortCutView removeFromSuperview];
		shortCutOut = FALSE;
	}
}

- (IBAction)configGestures:(id) sender{
	
	//if (configurationModalInTouchViewController == NULL) {
	//	configurationModalInTouchViewController = [[ConfigurationModal alloc] initWithNibName:@"ConfigurationModal" bundle:Nil];
	//}
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
						   forView:self.view cache:YES];
	
	[self.view addSubview:configurationModalInTouchViewController.view];
	
	[UIView commitAnimations];
	
	//[self.view addSubview:configurationModalInTouchViewController.view];
}

- (IBAction)lockScreen:(id)sender{
	if (screenLocked == TRUE) {
		//unlock the screen
		NSLog(@"Unlock the screen!");
		[(UIBarButtonItem *)sender setTitle:@"LockScreen"];
		
		// calculate minimum scale to perfectly fit image width, and begin at that scale  
		float minimumScale = [imageScrollView frame].size.width  / [imageScrollView frame].size.width;  
		[imageScrollView setMaximumZoomScale:5.0];
		[imageScrollView setMinimumZoomScale:minimumScale];
		//[imageScrollView setZoomScale:minimumScale];
		
		screenLocked = FALSE;
	}
	else {
		//lock the screen
		NSLog(@"Lock the screen!");
		[(UIBarButtonItem *)sender setTitle:@"Unlock"];
		
		//Set min. and max. to the same will disable pinch
		[imageScrollView setMaximumZoomScale:1.0];
		[imageScrollView setMinimumZoomScale:1.0];
		
		screenLocked = TRUE;
	}
}

/*
 Here are the functions in VNCCore
 - (void) sendCtrlPlusChar:(char)character;
 - (void) sendTab;
 - (void) sendAltPlusTab;
 - (void) sendAltPlusF4;
 - (void) sendCtrlPlusF4;
 - (void) sendCtrlPlusSpace; 
 */

- (IBAction) sendCtrlC:(id)sender{
	NSLog(@"sendCtrlC");
	[vnccore sendCtrlPlusChar:'c'];
}
- (IBAction) sendCtrlV:(id)sender{
	NSLog(@"sendCtrlV");
	[vnccore sendCtrlPlusChar:'v'];
}
- (IBAction) sendCtrlS:(id)sender{
	NSLog(@"sendCtrlS");
	[vnccore sendCtrlPlusChar:'s'];
}
- (IBAction) sendCtrlF4:(id)sender{
	NSLog(@"sendCtrlF4");
	[vnccore sendCtrlPlusF4];
}
- (IBAction) sendCtrlSpace:(id)sender{
	NSLog(@"sendCtrlSpace");
	[vnccore sendCtrlPlusSpace];
}
- (IBAction) sendTab:(id)sender{
	NSLog(@"sendTab");
	[vnccore sendTab];
}
- (IBAction) sendAltTab:(id)sender{
	NSLog(@"sendAltTab");
	[vnccore sendAltPlusTab];
}
- (IBAction) sendAltF4:(id)sender{
	NSLog(@"sendAltF4");
	[vnccore sendAltPlusF4];
}


#pragma mark Utility methods  

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {  
	
	CGRect zoomRect;  
	
	// the zoom rect is in the content view's coordinates.   
	//    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.  
	//    As the zoom scale decreases, so more content is visible, the size of the rect grows.  
	zoomRect.size.height = [imageScrollView frame].size.height / scale;  
	zoomRect.size.width  = [imageScrollView frame].size.width  / scale;  
	
	// choose an origin so as to get the right center.  
	zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);  
	zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);  
	
	return zoomRect;  
}  

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	if (scrollView.zoomScale!=1.0) {
		// Zooming, disable scrolling
		//scrollView.scrollEnabled = TRUE;
	} else {
		// Not zoomed, let the scroll view scroll
		//scrollView.scrollEnabled = FALSE;
	}
}

- (void)endConnection{
	[self.view removeFromSuperview];
}

- (void)dealloc {
	//[tapRecognizer release];
	//[swipeLeftRecognizer release];
	
	//[oneFingerDoubleTap release];
	[panRecognizer release];
	[imageView release];
	[image release];
	//[imageScrollView release];
	[imageScrollView release];
	[configurationModalInTouchViewController release];
    [super dealloc];
}


@end
