//
//  MapViewTouch.m
//  MapKitiPhone
//
//  Created by Matt on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewTouch.h"

@class MKMapView;

@implementation MapViewTouch

- (void) initializeGesturers{
	self.mapType = MKMapTypeSatellite;
	/*UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
	[self addGestureRecognizer:tapRec];
	[tapRec release];*/
}

- (IBAction) handleSingleTap: (UITapGestureRecognizer*)mySender{
	self.mapType = MKMapTypeSatellite;
}

@end
