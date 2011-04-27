    //
//  ConfigurationModal.m
//  RDPPrototype
//
//  Created by Karida on 12/02/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "ConfigurationModal.h"
#import "HelpPage.h"
#import "TouchViewController.h"

@implementation ConfigurationModal
@synthesize ConfigTable,helpView, switchInCell1, switchInCell2, switchInCell3, switchInCell4, switchInCell5, switchArray,activatedArray, tempActivatedArray,vnccoreInConfig,info;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
				
		//Initialize the switches and booleans variables
		switchInCell1 = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchInCell1 setOn:YES animated:NO];
		[switchInCell1 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		
		switchInCell2 = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchInCell2 setOn:YES animated:NO];
		[switchInCell2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		
		switchInCell3 = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchInCell3 setOn:YES animated:NO];
		[switchInCell3 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		
		switchInCell4 = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchInCell4 setOn:YES animated:NO];
		[switchInCell4 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		
		switchInCell5 = [[UISwitch alloc] initWithFrame:CGRectZero];
		[switchInCell5 setOn:YES animated:NO];
		[switchInCell5 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		
		switchArray = [[NSArray alloc] initWithObjects:switchInCell1,switchInCell2,switchInCell3,switchInCell4,switchInCell5,nil];
		
		//Initialize activated. each bit from 2^0 - 2^4 are used for indicating whether the switch is on or not.
		activated = 0;
		for (int i=0; i<5; i++) {
			activated += (1 << i); 
		}
		 
		tempActivated = activated;
		NSLog(@"activated = %d", activated);
		
		//Initialize the array.
		ConfigArray = [[NSMutableArray alloc] init];
	
		NSArray *generalInfoList = [NSArray arrayWithObjects:@"Connection Information", @"Help", nil];
		NSDictionary *generalInfoDict = [NSDictionary dictionaryWithObject:generalInfoList forKey:@"General"];
	
		NSArray *gestureList = [NSArray arrayWithObjects:@"Double-Finger Tap as Mouse Right Click", @"Three-Finger Pan Up to Maximize Current Window",
							@"Three-Finger Pan Down to Minimize Current Window",@"Three-Finger Pan Left to Switch Window",@"Long Press to Manipulate Current Window", nil];
		NSDictionary *gestureDic = [NSDictionary dictionaryWithObject:gestureList forKey:@"Gestures"];
	
		[ConfigArray addObject:generalInfoDict];
		[ConfigArray addObject:gestureDic];
		//[ConfigArray addObject:@"Log Out"];
		
		self.navigationItem.title = @"Configuration";
		
    }
    return self;
}

-(void)setVncInfo:(VNCCore *) vnc{
	
	vnccoreInConfig = vnc; 
	NSLog(@"Connected Info: port = %d", vnccoreInConfig.serverPort);
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


-(IBAction) cancellConfiguration: (id) sender{
	NSLog(@"Cancell Config");
		
	tempActivated = activated;
	
	for(int i=0;i<5;i++) {
		
		int temp = activated >> i;
		if (temp % 2 == 1) {
			//the ith is activated
			[[switchArray objectAtIndex:i] setOn:YES];
		}
		else {
			//it is deactivated
			[[switchArray objectAtIndex:i] setOn:NO];
		}
	}

	[self.view removeFromSuperview];
	
}
-(IBAction) saveConfiguration: (id) sender{
	NSLog(@"Save Config");
	
	activated = tempActivated;
	
	[self.view removeFromSuperview];
	
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
    // e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [ConfigArray count];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}
	else if (section == 1){
		return 5;
	}
	//else{
	//	return 1;
	//}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if(section == 0){
		return @"General Information";
	}
	else if (section == 1){
		return @"Gesture Selection";
	}
	//else {
	//	return @"End Connection";
	//}

}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([indexPath section] == 0) {
		//First Section, no switch
		static NSString *CellIdentifier = @"IPCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
		
		NSDictionary *dictionary = [ConfigArray objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"General"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		cell.textLabel.text = cellValue;
		
		return cell;
	}
	else if ([indexPath section] == 1){
		//Gesture Sets with switches
		static NSString *CellIdentifier = @"GestureCell";
		int row = [indexPath row];
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			
			[[switchArray objectAtIndex:row] setTag:row];
			cell.accessoryView = [switchArray objectAtIndex:row];
		}
		
		NSDictionary *dictionary = [ConfigArray objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Gestures"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		cell.textLabel.text = cellValue;
		
		return cell;
	}
	/*
	else {
		static NSString *CellIdentifier = @"LogOutCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		}
	
		cell.textLabel.text = @"Log Out";
		[cell setBackgroundColor:[UIColor colorWithRed:1 green:.2 blue:.5 alpha:.8]];
		
		return cell;
		
	}
	 */
}

- (void) switchChanged:(id)sender {
	UISwitch* switchControl = sender;
	
	NSLog(@"Before tempActivated = %d", tempActivated);
	
	//Tag ranges from 0 to 4
	int temp = tempActivated >> (switchControl.tag);
	
	if (temp % 2 == 1) {
		//the ith is activated
		//then deactivate it
		tempActivated = tempActivated & (~(1 << switchControl.tag));
		NSLog(@"it is Disabled!");
	}
	else {
		//it is deactivated, activate it
		tempActivated = tempActivated | (1 << switchControl.tag);
		NSLog(@"it is Enabled!");
	}

	NSLog(@"After tempActivated = %d", tempActivated);
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Dismiss the selected effect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([indexPath section] == 0) {
		if ([indexPath row] == 1) {
			//HelpPage
			NSLog(@"Help Page!");
			if (helpView == NULL) {
				helpView = [[HelpPage alloc] initWithNibName:@"HelpPage" bundle:[NSBundle mainBundle]];
			}
			
			//[self.view addSubview:helpView.view];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
								   forView:self.view cache:YES];
			
			[self.view addSubview:helpView.view];
			
			[UIView commitAnimations];
			
		}
		else {
			/*
			UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Connection Information"
															 message:@"currently not implemented?"
															delegate:self 
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil];
			[alert show];
			[alert release];
			 */
			if (info == NULL) {
				info = [[ConnectInfo alloc] initWithNibName:@"ConnectInfo" bundle:[NSBundle mainBundle]];
				info.initIP = [[UILabel alloc] init];
				[info.initIP setText:vnccoreInConfig.serverIP];
				
				info.initPort = [[UILabel alloc] init];
				[info.initPort setText:[NSString stringWithFormat:@"%i", vnccoreInConfig.serverPort]];
				
				//info.initIP.text = vnccoreInConfig.serverIP;
				//info.initPort.text = [NSString stringWithFormat:@"%i", vnccoreInConfig.serverPort];
				
				NSLog(@"it is %i and @%@",vnccoreInConfig.serverPort,vnccoreInConfig.serverIP );
				NSLog(@"it is @%@ and @%@",info.initIP.text,info.initPort.text );
			}
			
			
			//[self.view addSubview:helpView.view];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
								   forView:self.view cache:YES];
			
			[self.view addSubview:info.view];
			
			[UIView commitAnimations];
			
		}

	}
	/*
	else if([indexPath section] == 2){
		NSLog(@"Log Out!");
		
		[self.view removeFromSuperview];
		
		//[self.view.superview removeFromSuperview];
		//[(TouchViewController *)super endConnection];

	}
	 */
}


- (void)dealloc {
	[ConfigTable release];
	[ConfigArray release];
	[helpView release];
	
	[switchInCell1 release];
	[switchInCell2 release];
	[switchInCell3 release];
	[switchInCell4 release];
	[switchInCell5 release];
	[switchArray release];
	
	[vnccoreInConfig release];
	
    [super dealloc];
	
}


@end
