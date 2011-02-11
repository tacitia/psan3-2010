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
@synthesize image, imageView, configurationModalInTouchViewController;


- (void)viewDidLoad {
	[super viewDidLoad];
		
	[(UIScrollView *)self.view setBouncesZoom:YES];
	[(UIScrollView *)self.view setDelegate:self];
	[(UIScrollView *)self.view setClipsToBounds:YES];
	
	imageView = [[UIImageView alloc] initWithImage:image]; 
	imageView.userInteractionEnabled = YES;  
	
	/*
	CGRect imageFrame;
	if(image.size.width < image.size.height){
		 imageFrame = CGRectMake(0,0,image.size.height, image.size.height);
	}
	else {
		 imageFrame = CGRectMake(0,0,image.size.width, image.size.width);
	}
	 */

	CGRect imageFrame = CGRectMake(0,0,image.size.width, image.size.height);
	[imageView setFrame:imageFrame];
	
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth ); 
	 
	[(UIScrollView *)self.view setFrame:imageFrame];
	[(UIScrollView *)self.view setContentSize:CGSizeMake(imageView.frame.size.width, imageView.frame.size.height)];
	[self.view addSubview:imageView];

	
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
	
	
	// calculate minimum scale to perfectly fit image width, and begin at that scale  
	float minimumScale = [self.view frame].size.width  / [self.view frame].size.width;  
	//imageScrollView.maximumZoomScale = 1.0;  
	[(UIScrollView *)self.view setMaximumZoomScale:5.0];
	[(UIScrollView *)self.view setMinimumZoomScale:minimumScale];
	[(UIScrollView *)self.view setZoomScale:minimumScale];

	//imageScrollView.minimumZoomScale = minimumScale;  
	//imageScrollView.zoomScale = minimumScale;  
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
	//NSLog(@"SINGLE TAP!");
}  

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {  
	// zoom in  
	float newScale = [(UIScrollView *)self.view zoomScale] * ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[(UIScrollView *)self.view zoomToRect:zoomRect animated:YES];  
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
	// two-finger tap zooms out  
	//NSLog(@"DOUBLE TAP!");
	float newScale = [(UIScrollView *)self.view zoomScale] / ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[(UIScrollView *)self.view zoomToRect:zoomRect animated:YES];  
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
	zoomRect.size.height = [(UIScrollView *)self.view frame].size.height / scale;  
	zoomRect.size.width  = [(UIScrollView *)self.view frame].size.width  / scale;  
	
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
	[configurationModalInTouchViewController release];
    [super dealloc];
}


@end
