//
//  FirstViewController.h
//  NavigationController
//
//  Created by Chakra on 31/03/10.
//  Copyright 2010 Chakra Interactive Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKitiPhoneViewController.h"

@class MapKitiPhoneViewController;

@interface LoginViewController : UIViewController {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	
	IBOutlet MapKitiPhoneViewController *mapViewController;
}

@property(nonatomic, retain) IBOutlet UITextField *usernameField;
@property(nonatomic, retain) IBOutlet UITextField *passwordField;

@property(nonatomic, retain) MapKitiPhoneViewController *mapViewController;

- (IBAction)PressMe:(id)sender;

@end
