//
//  RootViewController.m
//  iNeedCaffeine
//
//  Created by John Harrison on 4/4/11.
//  Copyright 2011 Auburn University. All rights reserved.
//

#import "RootViewController.h"
#import "SettingViewController.h"
#import "CharReceiver.h"
#import "iNeedCaffeineAppDelegate.h"
#include <ctype.h>

@implementation RootViewController

@synthesize mapView;
@synthesize segControl;
@synthesize clearButton;

@synthesize myTapRecognizer;
@synthesize myColor;

- (id)init
{
    self = [super init];
    if (self) {
		multiByteLength = 0;
		multiBytePos = 0;
        myColor = MKPinAnnotationColorRed;
		memset(multiBytes, 0, sizeof(multiBytes));	
        memset(myStr, 0, sizeof(myStr));
    }
    NSLog(@"Basic Init was called");
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    self = [super initWithCoder:aDecoder];
    if (self){
		multiByteLength = 0;
		multiBytePos = 0;
        myColor = MKPinAnnotationColorRed;
		memset(multiBytes, 0, sizeof(multiBytes));
    }
    NSLog(@"RootViewController: Coder Init called");
    return self;
}

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		multiByteLength = 0;
		multiBytePos = 0;
        myColor = MKPinAnnotationColorRed;
		memset(multiBytes, 0, sizeof(multiBytes));
    }
    NSLog(@"Created RootViewController");
    return self;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
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

- (void)dealloc {
    [myTapRecognizer release];
	[segControl release];
	[mapView release];
    [super dealloc];
}

- (IBAction) changeMarkerType:(id) sender{
    NSLog(@"Changed Mark Type");
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
    
    NSLog(@"Color is now %d", myColor);
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Hi from the tap handler with color: %d", myColor);
	if(segControl.selectedSegmentIndex == 3)
	{
		//this means 'None' is selected, nothing gets placed on the map
		return;
	}
    
    NSLog(@"Hi from the tap handler %p", self);
	
	CGPoint touchPoint = [myTapRecognizer locationInView:mapView];
	CLLocationCoordinate2D touchMapCoordinate = 
	[mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    
    char buf[100] = "";
    sprintf(buf, "%c%2d %+3.4lf %+3.4lf%c", MSG_START, myColor, touchMapCoordinate.latitude, touchMapCoordinate.longitude, MSG_END);
	NSLog(@"Printing:  %s", buf);
    NSLog(@"Regions is: %+3.4lf %+3.4lf ", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    NSLog(@"Lat/Long %+3.4lf/%+3.4lf", touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    [[iNeedCaffeineAppDelegate getInstance].generator writeBytes: buf
                                                          length: strlen(buf)];
    
    [mapView addAnnotation:pa];
    [pa release];
}

- (IBAction) handleClearButton{
    NSLog(@"Handling Clear");
	[mapView removeAnnotations:mapView.annotations];
}

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    NSLog(@"mapView:viewForAnnotation: called");
    MKPinAnnotationView *customPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    NSLog(@"Color is now %d", myColor);
    customPinView.pinColor = myColor;
    customPinView.animatesDrop = NO;
    customPinView.canShowCallout = YES;
    return customPinView;
}

- (void)viewWillAppear:(BOOL)animated {
    MKCoordinateRegion reg; /* Auburn Regions */
    reg.center.latitude  =  32.597290;
    reg.center.longitude = -85.496149;
    reg.span.latitudeDelta  = 1.879535;
    reg.span.longitudeDelta = 1.922111;
    
    [mapView setRegion:reg animated:FALSE];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Testing stuff. Load Regnizer here");
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
	[mapView addGestureRecognizer:recognizer];
    self.myTapRecognizer = recognizer;

    NSLog(@"view is: %@ %@", mapView, recognizer);
	[recognizer release];
	
	self.title = @"Map View";
}


- (void) receivedChar:(char)input
{
    NSLog(@"Hi from receivedChar: %c", input);
	unsigned char byte = (unsigned char)input;
	NSMutableString *newstr = [NSMutableString string];
	
	/*
	 C0-DF 2byte
	 E0-EF 3byte
	 F0-F7 4byte
	 */
	if (multiBytePos < multiByteLength) {
		multiBytes[multiBytePos++] = byte;
		if (multiBytePos == multiByteLength){
			multiBytes[multiBytePos] = 0;
			NSString *utf8 = [NSString stringWithUTF8String: multiBytes];
			if (utf8 && [utf8 length]){
				[newstr appendString:utf8];
			}else{
				int i;
				for(i=0; i<multiByteLength; i++)
					[newstr appendFormat:@"(%x)", multiBytes[i]];
			}
		}
	}
    else {
		if (0xCF <= byte && byte <= 0xDF){
			multiByteLength = 2;
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else if (0xE0 <= byte && byte <= 0xEF){
			multiByteLength = 3;
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else if (0xF0 <= byte && byte <= 0xF7){
			multiByteLength = 4;			
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else {
			if(isascii(input)) {
				[newstr appendFormat:@"%c", input];
			}
            else {
				[newstr appendFormat:@"(%x)", byte];
			}
		}
	}
	
	if([newstr length] > 0){
        if ([newstr compare: @"\v"] == NSOrderedSame) {
            // end of string
            NSLog(@"Got end of string %s",  myStr);
            MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D touchMapCoordinate;
            
            int color;
            
            sscanf(myStr, "%d %lf %lf", &color, &touchMapCoordinate.latitude, &touchMapCoordinate.longitude);
            
            myColor = color;
            pa.coordinate = touchMapCoordinate;
            [mapView addAnnotation:pa];
            
            NSLog(@"Got: %d %lf %lf", color, touchMapCoordinate.latitude, touchMapCoordinate.longitude);
        }
        else if ([newstr compare: @"\t"] == NSOrderedSame) {
            // start of string
            memset(myStr, 0, sizeof(myStr));
            str_len = 0;
            NSLog(@"Got start of string with string = %s", myStr);
        }
        else {
            NSLog(@"middle bits");
            myStr[str_len++] = input;
        }
	}
}

@end
