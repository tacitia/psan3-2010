//
//  RDPPrototypeViewController.m
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright HKUST 2010. All rights reserved.
//

#import "RDPPrototypeViewController.h"

@implementation RDPPrototypeViewController

@synthesize hostTextField;
@synthesize portTextField;
@synthesize textMessage;
@synthesize outputTextView;
@synthesize displayImage;
//@synthesize rdpcore;
@synthesize vnccore;

- (IBAction) sendMessage: (id) sender {
	NSString* host = hostTextField.text;
	NSInteger port = [portTextField.text intValue];
//	rdpcore.serverIP = host;
//	rdpcore.serverPort = port;
//	const uint8_t *str = 
//	(uint8_t *) [textMessage.text cStringUsingEncoding:NSASCIIStringEncoding];	
//	[networkCommunicator sendMessage:str];
//	[rdpcore InitConnecting];
	vnccore.serverIP = host;
	vnccore.serverPort = port;
	[vnccore initConnection];
	textMessage.text = @"";
}

//-(void) touchsBegan: (NSSet *) touchs withEvent: (UIEvent *) event{
//	printf("testing");
//}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];		
	//self.rdpcore = [[RDPCore alloc] initWithViewController:self];
	self.vnccore = [[VNCCore alloc] initWithViewController:self];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}
@end
