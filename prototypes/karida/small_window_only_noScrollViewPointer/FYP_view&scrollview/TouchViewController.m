    //
//  TouchViewController.m
//  RDPPrototype
//
//  Created by Karida on 18/01/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "TouchViewController.h"

#define ZOOM_STEP 1.5  

@interface TouchViewController (UtilityMethods)  
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;  
@end  

@implementation TouchViewController
@synthesize swipeLeftRecognizer, tapRecognizer, longPressRecognizer, imageView;


- (void)viewDidLoad {
	[super viewDidLoad];
		
	[(UIScrollView *)self.view setBouncesZoom:YES];
	[(UIScrollView *)self.view setDelegate:self];
	[(UIScrollView *)self.view setClipsToBounds:YES];
	
	//imageScrollView.bouncesZoom = YES;  
	//imageScrollView.delegate = self;  
	//imageScrollView.clipsToBounds = YES;  
	 
	UIImage * image = [UIImage imageNamed:@"Windows.png"];
	imageView = [[UIImageView alloc] initWithImage:image];  
	imageView.userInteractionEnabled = YES;  
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth ); 
	[(UIScrollView *)self.view addSubview:imageView];
	//[imageScrollView addSubview:imageView];  
	
	[(UIScrollView *)self.view setContentSize:[image size]];  
	
	// add gesture recognizers to the image view  
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
	
	self.tapRecognizer = nil;
	self.swipeLeftRecognizer = nil;
	self.imageView = nil;
	//self.imageScrollView = nil; 
	
}

#pragma mark UIScrollViewDelegate methods  

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {  
	return imageView;  
}  

#pragma mark TapDetectingImageViewDelegate methods  

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {  
	// single tap does nothing for now  
}  

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {  
	// zoom in  
	float newScale = [(UIScrollView *)self.view zoomScale] * ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[(UIScrollView *)self.view zoomToRect:zoomRect animated:YES];  
}  

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {  
	// two-finger tap zooms out  
	float newScale = [(UIScrollView *)self.view zoomScale] / ZOOM_STEP;  
	CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];  
	[(UIScrollView *)self.view zoomToRect:zoomRect animated:YES];  
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
	[tapRecognizer release];
	[swipeLeftRecognizer release];
	[imageView release];
	//[imageScrollView release];
    [super dealloc];
}


@end