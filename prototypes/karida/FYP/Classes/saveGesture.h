//
//  saveGesture.h
//  RDPPrototype
//
//  Created by Karida on 21/04/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

//#import <Cocoa/Cocoa.h>

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface saveGesture : UIGestureRecognizer {
    
    //NSUInteger numberOfTouchesRequired;
	CGPoint startPoint;
	CGPoint endPoint;
	
	CGPoint midPoint;
	
	BOOL strokeUp;
	BOOL strokeDown;
	
	@public
	CGPoint firstPosition;
}

//@property(nonatomic) NSUInteger numberOfTouchesRequired; 
//@property(nonatomic) CGPoint midPoint;

- (void)reset;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end

