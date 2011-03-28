//
//  MapKitiPhoneViewController.h
//  MapKitiPhone
//
//  Created by Matt on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import <CommonCrypto/CommonCryptor.h>

@interface MapKitiPhoneViewController : UIViewController {
	IBOutlet MKMapView *mapView;
	IBOutlet UISegmentedControl *segControl;
	IBOutlet UIBarButtonItem *clearButton;
	
	UITapGestureRecognizer *myTapRecognizer;
	MKPinAnnotationColor myColor;
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segControl;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *clearButton;

@property(nonatomic, retain) UITapGestureRecognizer *myTapRecognizer;
@property(nonatomic) MKPinAnnotationColor myColor;

- (IBAction) changeMarkerType: (id)sender;
- (void) handleSingleTap;
- (IBAction) handleClearButton;

@end

