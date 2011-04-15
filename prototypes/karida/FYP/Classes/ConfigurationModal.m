    //
//  ConfigurationModal.m
//  RDPPrototype
//
//  Created by Karida on 12/02/2011.
//  Copyright 2011 HKUST. All rights reserved.
//

#import "ConfigurationModal.h"
#import "HelpPage.h"


@implementation ConfigurationModal
@synthesize ConfigTable,helpView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
		twoFingerTapActivated = TRUE;
	
		longPressActivated = TRUE;
	
		panRecognizerActivated = TRUE;
	
		threeFingerPanLeftRecognizerActivated = TRUE; 
		
		threeFingerPanUpRecognizerActivated = TRUE;
		
		threeFingerPanDownRecognizerActivated = TRUE;
		
		//Temporary Boolean Variables to store temporary user selections
		TemptwoFingerTapActivated = TRUE;
		TemplongPressActivated = TRUE;
		TempthreeFingerPanLeftRecognizerActivated = TRUE; 
		TempthreeFingerPanUpRecognizerActivated = TRUE;
		TempthreeFingerPanDownRecognizerActivated = TRUE;
		
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Initialize the array.
	ConfigArray = [[NSMutableArray alloc] init];
	
	NSArray *generalInfoList = [NSArray arrayWithObjects:@"Connection Information", @"Help", nil];
	NSDictionary *generalInfoDict = [NSDictionary dictionaryWithObject:generalInfoList forKey:@"General"];
	
	NSArray *gestureList = [NSArray arrayWithObjects:@"Double-Finger Tap as Mouse Right Click", @"Three-Finger Pan Up to Maximize Current Window",
							@"Three-Finger Pan Down to Minimize Current Window",@"Three-Finger Pan Left to Switch Window",@"Long Press to Manipulate Current Window", nil];
	NSDictionary *gestureDic = [NSDictionary dictionaryWithObject:gestureList forKey:@"Gestures"];
	
	[ConfigArray addObject:generalInfoDict];
	[ConfigArray addObject:gestureDic];
	
	self.navigationItem.title = @"Configuration";
}


-(IBAction) cancellConfiguration: (id) sender{
	NSLog(@"Cancell Config");
	//real boolean variables are not changed
	[self.view removeFromSuperview];
	//[self dismissModalViewControllerAnimated:YES];
}
-(IBAction) saveConfiguration: (id) sender{
	NSLog(@"Save Config");

	//Temporary Boolean Variables set to the real one
	twoFingerTapActivated = TemptwoFingerTapActivated;
	
	longPressActivated = TemplongPressActivated;
	
	threeFingerPanLeftRecognizerActivated = TempthreeFingerPanLeftRecognizerActivated; 
	threeFingerPanUpRecognizerActivated = TempthreeFingerPanUpRecognizerActivated;
	threeFingerPanDownRecognizerActivated = TempthreeFingerPanDownRecognizerActivated;
	
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
		return 5;
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
		cell.textLabel.text = cellValue;
		
		return cell;
	}
	else {
		//Gesture Sets with switches
		static NSString *CellIdentifier = @"GestureCell";
		int row = [indexPath row];
	
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
			UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
			cell.accessoryView = switchView;
			[switchView setOn:YES animated:NO];
			[switchView setTag:row];
			[switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			//[self performSelector:@selector(switchChanged:) withObject:row];
			[switchView release];
		}
		
		NSDictionary *dictionary = [ConfigArray objectAtIndex:indexPath.section];
		NSArray *array = [dictionary objectForKey:@"Gestures"];
		NSString *cellValue = [array objectAtIndex:indexPath.row];
		cell.textLabel.text = cellValue;
		
		return cell;
	}
}

- (void) switchChanged:(id)sender {
	UISwitch* switchControl = sender;
	//NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
	
	switch (switchControl.tag) {
		case 0:
			TemptwoFingerTapActivated = !TemptwoFingerTapActivated;
			if (TemptwoFingerTapActivated == FALSE) {
				NSLog(@"Two Finger Tap Disabled!");
			}
			else {
				NSLog(@"Two Finger Tap Enabled!");
			}
			break;
		case 1:
			TempthreeFingerPanUpRecognizerActivated = !TempthreeFingerPanUpRecognizerActivated;
			if (TempthreeFingerPanUpRecognizerActivated == FALSE) {
				NSLog(@"Three-Finger Pan Up Disabled!");
			}
			else {
				NSLog(@"Three-Finger Pan Up Enabled!");
			}
			break;
		case 2:
			TempthreeFingerPanDownRecognizerActivated = !TempthreeFingerPanDownRecognizerActivated;
			if (TempthreeFingerPanDownRecognizerActivated == FALSE) {
				NSLog(@"Three-Finger Pan Down Disabled!");
			}
			else {
				NSLog(@"Three-Finger Pan Down Enabled!");
			}
			break;
		case 3:
			TempthreeFingerPanLeftRecognizerActivated = !TempthreeFingerPanLeftRecognizerActivated;
			if (TempthreeFingerPanLeftRecognizerActivated == FALSE) {
				NSLog(@"Three-Finger Pan Left Disabled!");
			}
			else {
				NSLog(@"Three-Finger Pan Left Enabled!");
			}
			break;			
		case 4:
			TemplongPressActivated = !TemplongPressActivated;
			if (TemplongPressActivated == FALSE) {
				NSLog(@"Long Press Disabled!");
			}
			else {
				NSLog(@"Long Press Enabled!");
			}
			break;
			
		default:
			break;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//Dismiss the selected effect
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([indexPath section] == 0) {
		if ([indexPath row] == 1) {
			//HelpPage
			NSLog(@"Help Page!");
			helpView = [[HelpPage alloc] initWithNibName:@"HelpPage" bundle:[NSBundle mainBundle]];
			//[self.view addSubview:helpView.view];
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
								   forView:self.view cache:YES];
			
			[self.view addSubview:helpView.view];
			
			[UIView commitAnimations];
			
		}
	}

}


- (void)dealloc {
    [super dealloc];
}


@end
