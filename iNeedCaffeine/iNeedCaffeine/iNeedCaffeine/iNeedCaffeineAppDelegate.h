//
//  iNeedCaffeineAppDelegate.h
//  iNeedCaffeine
//
//  Created by John Harrison on 4/4/11.
//  Copyright 2011 Auburn University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioSession.h>
#import "RootViewController.h"
#import "AudioSignalAnalyzer.h"
#import "FSKSerialGenerator.h"
#import "FSKRecognizer.h"
#import "LoginViewController.h"

@class AudioSignalAnalyzer, FSKSerialGenerator, FSKRecognizer, LoginViewController;

@interface iNeedCaffeineAppDelegate : NSObject <UIApplicationDelegate, AVAudioSessionDelegate> {
	AudioSignalAnalyzer* analyzer;
    AVAudioSession *session;
	FSKSerialGenerator* generator;
	FSKRecognizer* recognizer;
    UIWindow* window;
    UINavigationController *myNavController;
    LoginViewController *view;
    RootViewController *rvc;
}

@property (nonatomic, retain) AVAudioSession* session;
@property (nonatomic, retain) AudioSignalAnalyzer* analyzer;
@property (nonatomic, retain) FSKSerialGenerator* generator;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *myNavController;
@property (nonatomic, retain) LoginViewController *view;
@property (nonatomic, retain) RootViewController *rvc;

+ (iNeedCaffeineAppDelegate*) getInstance;

@end
