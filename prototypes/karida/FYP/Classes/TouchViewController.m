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
@synthesize image, imageView, configurationModalInTouchViewController, imageScrollView, inputText, doneButton,inputTextView, vnccore, lockUnlockScreenBtn,
panRecognizer;


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
	
	//imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth ); 

	//imageScrollView = [[UIScrollView alloc] init];
	
	//imageScrollView = [[UIScrollView alloc] initWithFrame:[imageView frame]];
	
	[imageScrollView setBouncesZoom:YES];
	[imageScrollView setDelegate:self];
	//[imageScrollView setClipsToBounds:YES];
	
	//[(UIScrollView *)self.view setBouncesZoom:YES];
	//[(UIScrollView *)self.view setDelegate:self];
	//[(UIScrollView *)self.view setClipsToBounds:YES];
	
	[imageScrollView setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
	[imageScrollView addSubview:imageView];	
	
	imageScrollView.scrollEnabled = FALSE; 
	
	//[imageScrollView sizeToFit];
	
	//[imageScrollView settag:1];
	//[self presentModalViewController:imageScrollView animated:YES];

	//[self.view setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
	//[self.view setContentStretch:CGRectMake(0, 0, imageView.frame.size.width/2, imageView.frame.size.height/2)];
	//[self.view sizeToFit];
	
	//[self.view addSubview:imageScrollView];
		
	/*
	   add gesture recognizers to the image view 
	*/
	
	//taps
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	
	//two finger single tap to zoom-out
	UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];  
	
	//
	
	[twoFingerTap setNumberOfTouchesRequired:2];  
	
	[imageView addGestureRecognizer:singleTap];  
	[imageView addGestureRecognizer:twoFingerTap];  
	
	[singleTap release];  
	[twoFingerTap release];  
	
	//long press
	//display a window for exiting the app.
	UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];  
	[longPress setMinimumPressDuration:1];
	[imageView addGestureRecognizer:longPress];
	[longPress release];
	
	
	//Swipes
	UISwipeGestureRecognizer *recognizer;
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
	recognizer.numberOfTouchesRequired = 3;
	recognizer.delaysTouchesBegan = TRUE;
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
	recognizer.numberOfTouchesRequired = 3;
	recognizer.delaysTouchesBegan = TRUE;
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
	recognizer.numberOfTouchesRequired = 3;
	recognizer.delaysTouchesBegan = TRUE;
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	recognizer.numberOfTouchesRequired = 3;
	recognizer.delaysTouchesBegan = TRUE;
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
	/*
	   Gestures specific to locked screen
	 */
	
	//One finger Double Tap to open an directory
	/*
	oneFingerDoubleTap= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
	[oneFingerDoubleTap setNumberOfTapsRequired:2]; 
	//Do not invoke single tap to recognize double tap
	[singleTap requireGestureRecognizerToFail : oneFingerDoubleTap];
	 */
	

	//Pan
	panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[imageView addGestureRecognizer:panRecognizer];
	
	threeFingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreeFingerPan:)];
	[threeFingerPanRecognizer setMinimumNumberOfTouches:3];
	[threeFingerPanRecognizer setMaximumNumberOfTouches:3];
	[imageView addGestureRecognizer:threeFingerPanRecognizer];
	
	//[panRecognizer requireGestureRecognizerToFail:threeFingerPanRecognizer];
			
	/*
	// calculate minimum scale to perfectly fit image width, and begin at that scale  
	float minimumScale = [self.view frame].size.width  / [self.view frame].size.width;  
	//imageScrollView.maximumZoomScale = 1.0;  
	[(UIScrollView *)self.view setMaximumZoomScale:5.0];
	[(UIScrollView *)self.view setMinimumZoomScale:minimumScale];
	[(UIScrollView *)self.view setZoomScale:minimumScale];

	//imageScrollView.minimumZoomScale = minimumScale;  
	//imageScrollView.zoomScale = minimumScale;  
	 
	 */
	
	// calculate minimum scale to perfectly fit image width, and begin at that scale  
	float minimumScale = [imageScrollView frame].size.width  / [imageScrollView frame].size.width;  
	//imageScrollView.maximumZoomScale = 1.0;  
	[imageScrollView setMaximumZoomScale:5.0];
	[imageScrollView setMinimumZoomScale:minimumScale];
	[imageScrollView setZoomScale:minimumScale];
	
	
	//Default the keyboard should not present
	keyboardIsOut = FALSE;
	
	//Default screen should not be locked
	screenLocked = FALSE;
	
	//Notification sent when the keyboard resigns
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
	
}

- (void)updateImage:(UIImage *)myimage {
//	NSLog(@"update image!");
	image = myimage;
	imageView.image = image;
	[imageView setImage:image];
	[imageScrollView setNeedsDisplay];
	[self.view setNeedsDisplay];
}

// When user wants to insert text
- (IBAction)editText:(id)sender{
	NSLog(@"edit the text!!");
	
	
	inputText.hidden = FALSE;
	doneButton.hidden = FALSE;
	//inputTextView.hidden = FALSE;
	
	//[self.view bringSubviewToFront:inputTextView];
	
	
	//UITextView * tv = [[UITextView alloc] initWithFrame:(CGRectMake(0, self.view.frame.size.height - 100, self.view.frame.size.width, self.view.frame.size.height))];
	//tv.text = @"Start Editing...";
	//[tv becomeFirstResponder];
	//tv.editable = YES;
	//[tv setScrollEnabled:YES];
	
	//[imageScrollView removeFromSuperview];
	//[self.imageScrollView addSubview:tv];
	//[self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
	//[self.view sendSubviewToBack:imageScrollView];
	//[self.view addSubview:tv];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {	
	//move the view up by 100 pixels. works but should be put into the notification fo inputtext textfield.
	keyboardIsOut = TRUE;
	NSLog(@"called textfield begin editing");
	self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y - 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
	[self.inputTextView becomeFirstResponder];
	
}


- (IBAction)doneButtonPressed:(id)sender{
	
	/*
	  send msg to server
	  content is inputText.text
	 */
	//Implementation
	
	
	//inputText.hidden = YES;
	//doneButton.hidden = YES;
	//inputTextView.hidden = YES;
	
	//self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y + 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);

	keyboardIsOut = FALSE;
	
	//[sender resignFirstResponder];
	//[self.inputText resignFirstResponder];

	NSLog(@"%@", self.inputText.text);
	
}

-(void)keyboardWillDisappear:(NSNotification *) notification {
	NSLog(@"keyboard disappear");
	/*
	if (keyboardIsOut == TRUE) {
		inputText.hidden = YES;
		doneButton.hidden = YES;
		inputTextView.hidden = YES;
		
		self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y + 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
		keyboardIsOut = FALSE;

	}
	 */
	
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
	
	inputText = [[UITextField alloc] initWithFrame:CGRectMake(25, 25, 400, 50)];
	[inputText becomeFirstResponder];
	//inputText.delegate = self.inputText;
	inputText.returnKeyType = UIReturnKeyDone;
	inputText.autocapitalizationType = UITextAutocapitalizationTypeWords;
	[inputText addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];     
	[imageView addSubview:inputText];
	//[imageScrollView setNeedsDisplay];
	//[self.view setNeedsDisplay];

//	CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
//	CGPoint adjustedTouchLocation = CGPointMake(touchLocation.x * imageView.frame.size.width / imageScrollView.frame.size.width,
//												touchLocation.y * imageView.frame.size.height / imageScrollView.frame.size.height);
	
	CGPoint touchLocation = [gestureRecognizer locationInView:imageView];
	

	[vnccore sendLeftClickEventAtPosition:touchLocation];
	/*
	test for changing display image
	 */
	//[self updateImage:@"tap.png"];
	
	//[self viewDidLoad];
	
	//[self.view addSubview:touchViewController.view];	
	
	/*test end*/
}  

- (IBAction)textFieldDone:(id)sender {
	NSLog(@"text done!");
	[sender resignFirstResponder];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	/*
	NSLog(@"Single Finger Double Tap!");
	// single finger double tap is to zoom in  
	float newScale = [imageScrollView zoomScale] * ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	
	[imageScrollView zoomToRect:zoomRect animated:YES];  
	 */
	
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
	// two-finger tap zooms out  
	NSLog(@"Right Click!");
	/*
	float newScale = [imageScrollView zoomScale] / ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[imageScrollView zoomToRect:zoomRect animated:YES];  
	 */
}  

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)gestureRecognizer {
    //CGPoint location = [gestureRecognizer locationInView:self.view];
	
	
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		NSLog(@"left swipe");
        //location.x -= 220.0;
    }
    else {
		NSLog(@"Right Swipe");
        //location.x += 220.0;
    }
	
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
		NSLog(@"Up Swipe");
       // location.y -= 220.0;
    }
    else {
		NSLog(@"Down Swipe");
       // location.y += 220.0;
    }
	
	//[UIView beginAnimations:nil context:NULL];
	//[UIView setAnimationDuration:0.55];
	//imageView.alpha = 0.0;
	//imageView.center = location;
	//[UIView commitAnimations];
	
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
	
}

-(void)handleThreeFingerPan:(UIPanGestureRecognizer *)gestureRecognizer {
	//For minimize&maximize window, and switch between different windows function
	//NSLog(@"Three Finger Pan!");
	//NSLog(@"Count = %d", countThreeFingerPan);
	
	//Find the start and end points
	//CGPoint startLocation;
	//CGPoint endLocation;
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {		
		startLocation = [gestureRecognizer locationInView:self.imageView];
		NSLog(@"start for three fingers is : ( %f , %f )", startLocation.x, startLocation.y);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {		
		endLocation = [gestureRecognizer locationInView:self.imageView];
        NSLog(@"end for three fingers is : ( %f , %f )", endLocation.x, endLocation.y);
		
		//Identify whether it is up, down or left pan
		//double diffX = fabs(startLocation.x - endLocation.x);
		//double diffY = fabs(startLocation.y - endLocation.y);
		
		//NSLog(@"diff X = %f and diff Y = %f", diffX, diffY);
		
		if (startLocation.y > endLocation.y) {
			//it is an up pan
			//Maximize the current window
			NSLog(@"Up pan!");
		}
		else {
			//it is a down pan
			//Minimize the current window
			NSLog(@"Down Pan");
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

	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		//Function invoked again but do nothing
	}
	else{
		NSLog(@"Long Press!");
		configurationModalInTouchViewController = [[ConfigurationModal alloc] initWithNibName:@"ConfigurationModal" bundle:Nil];
		[self.view addSubview:configurationModalInTouchViewController.view];
		//[self presentModalViewController:configurationModalInTouchViewController animated:YES];
	}
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
