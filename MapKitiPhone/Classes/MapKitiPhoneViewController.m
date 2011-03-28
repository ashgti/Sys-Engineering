//
//  MapKitiPhoneViewController.m
//  MapKitiPhone
//
//  Created by Matt on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapKitiPhoneViewController.h"
#import "SettingViewController.h"

@implementation MapKitiPhoneViewController

@synthesize mapView;
@synthesize segControl;
@synthesize clearButton;

@synthesize myTapRecognizer;
@synthesize myColor;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	UITapGestureRecognizer* myRecog;
	myRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
	[mapView addGestureRecognizer:myRecog];
	myTapRecognizer = myRecog;
	[myRecog release];
	
	myColor = MKPinAnnotationColorRed;
	
	self.title = @"Map View";
}



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
	[segControl release];
	[mapView release];
    [super dealloc];
}

- (IBAction) changeMarkerType:(id) sender{
	switch (segControl.selectedSegmentIndex) {
		case 0:
		{
			myColor = MKPinAnnotationColorRed;
			break;
		}
		case 1:
		{
			myColor = MKPinAnnotationColorPurple;
			break;
		}
		case 2:
		{
			myColor = MKPinAnnotationColorGreen;
			break;
		}
	}
}

- (void) handleSingleTap{
	if(segControl.selectedSegmentIndex == 3)
	{
		//this means 'None' is selected, nothing gets placed on the map
		return;
	}
	
	CGPoint touchPoint = [myTapRecognizer locationInView:mapView];
	CLLocationCoordinate2D touchMapCoordinate = 
	[mapView convertPoint:touchPoint toCoordinateFromView:mapView];
	
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
	
    [mapView addAnnotation:pa];
    [pa release];
}

- (IBAction) handleClearButton{
	[mapView removeAnnotations:mapView.annotations];
}

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    MKPinAnnotationView *customPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    customPinView.pinColor = myColor;
    customPinView.animatesDrop = NO;
    customPinView.canShowCallout = YES;
    return customPinView;
}

@end
