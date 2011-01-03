//
//  MultiTouchController.m
//  RDPPrototype
//
//  Created by LIU Haixiang on 03/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiTouchViewController.h"



@implementation MultiTouchViewController



//---fired when the user finger(s) touches the screen---
-(BOOL) canBecomeFirstResponder{
	return YES;
}
-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
	
	
	
    //---get all touches on the screen---
	
    NSSet *allTouches = [event allTouches];
	
	printf("asdasd");
	
    //---compare the number of touches on the screen---
	
    switch ([allTouches count])
	
    {
			
			//---single touch---
			
        case 1: {
			
            //---get info of the touch---
			
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
			
			
			
            //---compare the touches---
			
            switch ([touch tapCount])
			
            {
					
					//---single tap---
					
                case 1: {
					
                    //imageView.contentMode = UIViewContentModeScaleAspectFit;
					
                } break;
					
					
					
					//---double tap---
					
                case 2: {
					
                    //imageView.contentMode = UIViewContentModeCenter;
					
                } break;
					
            }
			
        }  break;
			
    }
	
} 

- (void)dealloc {
	
    //[imageView release];
	
    [super dealloc];
	
}

@end