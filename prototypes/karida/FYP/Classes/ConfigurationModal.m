    //
//  ConfigurationModal.m
//  RDPPrototype
//
//  Created by Karida on 12/02/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "ConfigurationModal.h"


@implementation ConfigurationModal
@synthesize ConfigTable;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	twoFingerTapActivated = TRUE;
	
	longPressActivated = TRUE;
	
	panRecognizerActivated = TRUE;
	
	threeFingerPanRecognizerActivated = TRUE;
	
	//Initialize the array.
	ConfigArray = [[NSMutableArray alloc] init];
	
	NSArray *generalInfoList = [NSArray arrayWithObjects:@"Connection Information", @"Help", nil];
	NSDictionary *generalInfoDict = [NSDictionary dictionaryWithObject:generalInfoList forKey:@"General"];
	
	NSArray *gestureList = [NSArray arrayWithObjects:@"Double-Finger Tap as Mouse Right Click", @"Three-Finger Pan Up to Maximize Current Window",
							@"Three-Finger Pan Down to Minimize Current Window",@"Three-Finger Pan Left to Switch Window", nil];
	NSDictionary *gestureDic = [NSDictionary dictionaryWithObject:gestureList forKey:@"Gestures"];
	
	[ConfigArray addObject:generalInfoDict];
	[ConfigArray addObject:gestureDic];
	
	self.navigationItem.title = @"Configuration";
}


-(IBAction) cancellConfiguration: (id) sender{
	NSLog(@"Cancell Config");
	[self.view removeFromSuperview];
	//[self dismissModalViewControllerAnimated:YES];
}
-(IBAction) saveConfiguration: (id) sender{
	NSLog(@"Save Config");
	//[self dismissModalViewControllerAnimated:YES];
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
	else {
		return 4;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0)
		return @"General Information";
	else
		return @"Gesture Selection";
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
		cell.text = cellValue;
		
		return cell;
	}
	else {
		//Gesture Sets with switches
		static NSString *CellIdentifier = @"GestureCell";
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
			cell.accessoryView = switchView;
			[switchView setOn:NO animated:NO];
			[switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			[switchView release];
		}
		
		NSDictionary *dictionary = [ConfigArray objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Gestures"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		cell.text = cellValue;
		
		return cell;
	}
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/*
	 NSDictionary *dictionary = [listOfItems objectAtIndex:indexPath.section];
	 NSArray *array = [dictionary objectForKey:@"Countries"];
	 NSString *selectedCountry = [array objectAtIndex:indexPath.row];
	 
	 //Initialize the detail view controller and display it.
	 DetailViewController *dvController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:[NSBundle mainBundle]];
	 dvController.selectedCountry = selectedCountry;
	 [self.navigationController pushViewController:dvController animated:YES];
	 [dvController release];
	 dvController = nil;	 
	 
	 */
}


- (void)dealloc {
    [super dealloc];
}


@end
