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
@synthesize textMessage;
@synthesize outputTextView;
@synthesize displayImage;
@synthesize vnccore;
@synthesize touchViewController;

- (IBAction) sendMessage: (id) sender {
	/*
	NSString* host = hostTextField.text;
	NSInteger port = [portTextField.text intValue];

	vnccore.serverIP = host;
	vnccore.serverPort = port;
	[vnccore initConnection];
	textMessage.text = @"";
	 */
	/*
	UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0,0,500,500)];
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,20, 500,500)];
	newLabel.text = @"Karida Here";
	[newView addSubview: newLabel];
	[self.view addSubview: newView];
	[newLabel release];
	[newView release];
	*/
	
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
		touchViewController.modalPresentationStyle = UIModalPresentationFullScreen;
	}
	
	//NSLog(@"showing %@",touchViewController);
	
	[self.view addSubview:touchViewController.view];
	
}




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
	
	self.touchViewController = nil;
}


- (void)dealloc {
    [super dealloc];
	
	[touchViewController release];
}
@end
