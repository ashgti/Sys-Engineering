//
//  WiFiAppDelegate.h
//  WiFi
//
//  Created by Adam Jeter on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WiFiViewController;

@interface WiFiAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    WiFiViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet WiFiViewController *viewController;

@end

