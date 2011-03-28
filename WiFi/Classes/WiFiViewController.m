//
//  WiFiViewController.m
//  WiFi
//
//  Created by Adam Jeter on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WiFiViewController.h"
#import "AsyncUDPSocket.h"

@implementation WiFiViewController

-(id)init
{
	if (self = [super init])
	{
		asyncUdpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
		[asyncUdpSocket enableBroadcast:YES error:nil];
		[asyncUdpSocket bindToPort:12345 error:nil];
		[asyncUdpSocket receiveWithTimeout:-1 tag:0];
	}
	return self;
}

@synthesize lat1;
@synthesize lat2;
@synthesize long1;
@synthesize long2;
@synthesize rgb;

-(IBAction) SendPacket
{
	NSArray* dataPackage;
	dataPackage = [NSArray arrayWithObjects: lat1.text, lat2.text, long1.text, long2.text, rgb.text, nil];
	NSData* sendPack = [NSKeyedArchiver archivedDataWithRootObject:dataPackage];
	[asyncUdpSocket sendData:sendPack toHost:@"255.255.255.255" port:12345 withTimeout:3 tag:0];
	
	/*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Success"
													message:@"Sending Packet"
												   delegate:nil
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"OK", nil];*/
	//[alert autorelease];
	//[alert show];
}

-(void) onUdpSocket:(AsyncUdpSocket*)sock didReceiveData:(NSData*)data withTag:(long)tag fromHost:(NSString*)host port:(UInt16)port
{
	NSMutableArray* receivedDataPackage = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSString* dataRead = [[receivedDataPackage objectAtIndex:0] stringByAppendingString:[receivedDataPackage objectAtIndex:1]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Recieved"
													message:dataRead
												   delegate:nil
										  cancelButtonTitle:@"Cancel" 
										  otherButtonTitles:@"OK", nil];
	[alert autorelease];
	[alert show];
}
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[asyncUdpSocket release];
    [super dealloc];
}

@end
