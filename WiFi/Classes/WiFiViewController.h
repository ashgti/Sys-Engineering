//
//  WiFiViewController.h
//  WiFi
//
//  Created by Adam Jeter on 3/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"

@interface WiFiViewController : UIViewController {
	IBOutlet UITextField *lat1;
	IBOutlet UITextField *lat2;
	IBOutlet UITextField *long1;
	IBOutlet UITextField *long2;
	IBOutlet UITextField *rgb;
	IBOutlet UIButton *SendButton;
	AsyncUdpSocket *asyncUdpSocket;
}

@property (nonatomic, retain) IBOutlet UITextField *lat1;
@property (nonatomic, retain) IBOutlet UITextField *lat2;
@property (nonatomic, retain) IBOutlet UITextField *long1;
@property (nonatomic, retain) IBOutlet UITextField *long2;
@property (nonatomic, retain) IBOutlet UITextField *rgb;

-(IBAction) SendPacket;

@end

