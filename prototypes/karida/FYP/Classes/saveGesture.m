//
//  saveGesture.m
//  RDPPrototype
//
//  Created by Karida on 21/04/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "saveGesture.h"


@implementation saveGesture
//@synthesize midPoint;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"Touch Begin!");
	firstPosition = [[touches anyObject] locationInView:self.view];
	//NSLog(@"Touch begin position is : ( %f , %f )", firstPosition.x, firstPosition.y);
	
    [super touchesBegan:touches withEvent:event];
    if ([touches count] != 1) {
		NSLog(@"Touch != 1");
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    if (!strokeUp) {
		//NSLog(@"strokeUp == false");
        // on downstroke, both x and y increase in positive direction
        if (nowPoint.x >= prevPoint.x && nowPoint.y >= prevPoint.y) {
            midPoint = nowPoint;
            // upstroke has increasing x value but decreasing y value
        } else if (nowPoint.x >= prevPoint.x && nowPoint.y <= prevPoint.y) {
            strokeUp = YES;
			self.state == UIGestureRecognizerStatePossible;
        } else {
			//NSLog(@"2");
            self.state = UIGestureRecognizerStateFailed;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"TouchesEnded called");
    [super touchesEnded:touches withEvent:event];
    if ((self.state == UIGestureRecognizerStatePossible) && strokeUp) {
		NSLog(@"Save Recognized!");
        self.state = UIGestureRecognizerStateRecognized;
		
		
    }
	else {
		self.state = UIGestureRecognizerStateFailed;
	}

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    midPoint = CGPointZero;
    strokeUp = NO;
    self.state = UIGestureRecognizerStateFailed;
}

- (void)reset {
    [super reset];
    midPoint = CGPointZero;
    strokeUp = NO;
}

@end
