//
//  MapViewTouch.h
//  MapKitiPhone
//
//  Created by Matt on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class MKMapView;

@interface MapViewTouch : MKMapView {
	
}

- (void) initializeGesturers;
- (IBAction) handleSingleTap: (UITapGestureRecognizer*)mySender;

@end