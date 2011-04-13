//
//  FirstViewController.m
//  NavigationController
//
//  Created by Chakra on 31/03/10.
//  Copyright 2010 Chakra Interactive Pvt Ltd. All rights reserved.
//

#import "iNeedCaffeineAppDelegate.h"
#import "LoginViewController.h"
#import "RootViewController.h"

@implementation LoginViewController

@synthesize usernameField;
@synthesize passwordField;
@synthesize mapViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Login";
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    NSLog(@"LoginViewController did Appear");
}

- (void)awakeFromNib
{
	self.title = @"Login - Level 1";
}

- (IBAction)PressMe:(id)sender
{
    [iNeedCaffeineAppDelegate getInstance].passwd = passwordField.text;
	[[self navigationController] pushViewController:mapViewController animated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
