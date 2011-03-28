//
//  FirstViewController.m
//  NavigationController
//
//  Created by Chakra on 31/03/10.
//  Copyright 2010 Chakra Interactive Pvt Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "MapKitiPhoneViewController.h"

@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;

@synthesize mapViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Login";
}

- (IBAction)PressMe:(id)sender
{
	[[self navigationController] pushViewController:mapViewController animated:YES];
}


- (void)dealloc {
    [super dealloc];
}


@end
