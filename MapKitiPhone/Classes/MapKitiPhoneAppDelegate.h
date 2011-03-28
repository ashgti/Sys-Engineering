//
//  MapKitiPhoneAppDelegate.h
//  MapKitiPhone
//
//  Created by Matt on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapKitiPhoneAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    IBOutlet UINavigationController *myNavController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *myNavController;

@end