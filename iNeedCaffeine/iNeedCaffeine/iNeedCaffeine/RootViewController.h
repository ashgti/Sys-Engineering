//
//  RootViewController.h
//  iNeedCaffeine
//
//  Created by John Harrison on 4/4/11.
//  Copyright 2011 Auburn University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import <CommonCrypto/CommonCryptor.h>
#import "CharReceiver.h"

@interface RootViewController : UIViewController<UIGestureRecognizerDelegate, CharReceiver> {
	IBOutlet MKMapView *mapView;
	IBOutlet UISegmentedControl *segControl;
	IBOutlet UIBarButtonItem *clearButton;
	
	UITapGestureRecognizer *myTapRecognizer;
	MKPinAnnotationColor myColor;
    
	int multiByteLength;
	int multiBytePos;
    unsigned char multiBytes[16];
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *segControl;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *clearButton;

@property(nonatomic, retain) UITapGestureRecognizer *myTapRecognizer;
@property(nonatomic) MKPinAnnotationColor myColor;

- (IBAction) changeMarkerType: (id)sender;
- (void) handleSingleTap: (UITapGestureRecognizer *)recognizer;
- (IBAction) handleClearButton;

@end

