//
//  RDPPrototypeViewController.m
//  RDPPrototype
//
//  Created by Guo Hua on 06/11/2010.
//  Copyright HKUST 2010. All rights reserved.
//

#import "RDPPrototypeViewController.h"
#import "TouchViewController.h"

@implementation RDPPrototypeViewController

@synthesize hostTextField;
@synthesize portTextField;
//@synthesize textMessage;
//@synthesize outputTextView;
//@synthesize displayImage;
@synthesize vnccore;
@synthesize touchViewController;

- (IBAction) sendMessage: (id) sender {
	
	NSString* host = hostTextField.text;
	NSInteger port = [portTextField.text intValue];

	vnccore.serverIP = host;
	vnccore.serverPort = port;
	
	[vnccore initConnection];
	/*
	if (!isShowingDesktop)
	{
        [self presentModalViewController:self.touchViewController animated:YES];
        isShowingDesktop = YES;
    }
	else 
	{
        [self dismissModalViewControllerAnimated:YES];
        isShowingDesktop = NO;
    }   
	 */
	
	if(touchViewController == nil){
		touchViewController = [[TouchViewController alloc] initWithNibName:@"TouchViewController" bundle:Nil];
		//touchViewController.modalPresentationStyle = UIModalPresentationFullScreen;
		
	}
	
	UIImage *tmpimage = [UIImage imageNamed:@"loading.png"];
	[touchViewController setImage:tmpimage];
	touchViewController.vnccore = self.vnccore;
	[tmpimage release];
	
	
	
	//NSLog(@"showing %@",touchViewController);
	
	[self.view addSubview:touchViewController.view];
	//［self.view presentModalViewController
	
		
}


#pragma mark -
#pragma mark NetworkCommunicatorDelegate Methods

- (void)connectionDidFinishSuccessfully {
}


- (void)networkErrorOccurred {
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
													 message:@"Connection failed"
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil] autorelease];
	[alert show];
	[alert release];
	if ([[self.view subviews] count] > 0) {
		UIView *rootSubview = [[self.view subviews] objectAtIndex:0];
		[rootSubview removeFromSuperview];
	}	
	
//	[self.view subviews];
}


#pragma mark -
#pragma mark View Life Cycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];		
	//self.rdpcore = [[RDPCore alloc] initWithViewController:self];
	self.vnccore = [[VNCCore alloc] initWithViewController:self];
	
	/*
	TouchViewController *touchController  = [TouchViewController new];
	isShowingDesktop = NO; 
	self.touchViewController = touchController;
	[touchController release];
	 */
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	self.touchViewController = nil;
}


- (void)dealloc {
	[touchViewController release];

    [super dealloc];	
}
@end
