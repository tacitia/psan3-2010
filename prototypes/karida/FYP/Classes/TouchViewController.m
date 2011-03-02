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
@synthesize image, imageView, configurationModalInTouchViewController, imageScrollView, inputText, doneButton,inputTextView;


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
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];  
	UITapGestureRecognizer *twoFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];  
	
	[doubleTap setNumberOfTapsRequired:2];  
	[twoFingerTap setNumberOfTouchesRequired:2];  
	
	[imageView addGestureRecognizer:singleTap];  
	[imageView addGestureRecognizer:doubleTap];  
	[imageView addGestureRecognizer:twoFingerTap];  
	
	[singleTap release];  
	[doubleTap release];  
	[twoFingerTap release];  
	
	//long press
	//display a window for exiting the app.
	UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];  
	[longPress setMinimumPressDuration:1];
	[imageView addGestureRecognizer:longPress];
	[longPress release];
	
	/*
	//Swipes
	UISwipeGestureRecognizer *recognizer;
	
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionDown)];
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [imageView addGestureRecognizer:recognizer];
    [recognizer release];
	*/
	
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
	
}

- (void)updateImage:(NSString *)imageNameString {
	NSLog(@"update image!");
	image = [UIImage imageNamed:@"tap.png"];
	imageView.image = image;
	[imageView setImage:image];
	[imageScrollView setNeedsDisplay];
	[self.view setNeedsDisplay];
}

//- (IBAction) uploadText(){
//	printf("Here is the input text: %s", inputText.text);
//	[inputText resignFirstResponder];
//

// When user wants to insert text
- (IBAction)editText:(id)sender{
	NSLog(@"edit the text!!");
	
	
	inputText.hidden = FALSE;
	doneButton.hidden = FALSE;
	inputTextView.hidden = FALSE;
	
	[self.view bringSubviewToFront:inputTextView];
	
	
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
	
	NSLog(@"called textfield begin editing");
	self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y - 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
	
}


- (IBAction)doneButtonPressed:(id)sender{
	
	/*
	  send msg to server
	  content is inputText.text
	 */
	//Implementation
	
	
	inputText.hidden = YES;
	doneButton.hidden = YES;
	inputTextView.hidden = YES;
	
	self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x, self.inputTextView.frame.origin.y + 348, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);

	
	//[sender resignFirstResponder];
	[self.inputText resignFirstResponder];
	
}



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
	// zoom in  
	float newScale = [imageScrollView zoomScale] * ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[imageScrollView zoomToRect:zoomRect animated:YES];  
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
	// two-finger tap zooms out  
	//NSLog(@"DOUBLE TAP!");
	float newScale = [imageScrollView zoomScale] / ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[imageScrollView zoomToRect:zoomRect animated:YES];  
}  
/*
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.view];
	
	
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        location.x -= 220.0;
    }
    else {
        location.x += 220.0;
    }
	
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionUp) {
        location.y -= 220.0;
    }
    else {
        location.y += 220.0;
    }
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.55];
	imageView.alpha = 0.0;
	imageView.center = location;
	[UIView commitAnimations];
	
}
 */

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	NSLog(@"Long Press!");
	configurationModalInTouchViewController = [[ConfigurationModal alloc] initWithNibName:@"ConfigurationModal" bundle:Nil];
	[self presentModalViewController:configurationModalInTouchViewController animated:YES];
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

- (void)dealloc {
	//[tapRecognizer release];
	//[swipeLeftRecognizer release];
	[imageView release];
	[image release];
	//[imageScrollView release];
	[imageScrollView release];
	[configurationModalInTouchViewController release];
    [super dealloc];
}


@end
