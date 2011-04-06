//
//  iNeedCaffeineAppDelegate.m
//  iNeedCaffeine
//
//  Created by John Harrison on 4/4/11.
//  Copyright 2011 Auburn University. All rights reserved.
//

#import "iNeedCaffeineAppDelegate.h"

@implementation iNeedCaffeineAppDelegate

@synthesize session;
@synthesize generator;
@synthesize analyzer;
@synthesize window=_window;
@synthesize myNavController=_myNaveController;
@synthesize view;
@synthesize rvc;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"HI");
    [window addSubview:[myNavController view]];
	[window makeKeyAndVisible];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.myNavController;
            
    [window addSubview:[myNavController view]];
	[window makeKeyAndVisible];

    session = [AVAudioSession sharedInstance];
	session.delegate = self;
	if (session.inputIsAvailable) {
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
	}
    else {
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[session setActive:YES error:nil];
	[session setPreferredIOBufferDuration:0.023220 error:nil];
    
	recognizer = [[FSKRecognizer alloc] init];
	//[recognizer addReceiver: myNavController];
    
	generator = [[FSKSerialGenerator alloc] init];
	[generator play];
    
	analyzer = [[AudioSignalAnalyzer alloc] init];
	// [analyzer addRecognizer:recognizer];
    
	if(session.inputIsAvailable){
		[analyzer record];
	}

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [session setActive:NO error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
   [session setActive:YES error:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [view release];
    [rvc release];
    [_window release];
    [session release];
    [_myNaveController release];
    [super dealloc];
}


- (void)restartAnalyzerAndGenerator:(BOOL)isInputAvailable
{
	session = [AVAudioSession sharedInstance];
	[session setActive:YES error:nil];
	[analyzer stop];
	[generator stop];
	if(isInputAvailable){
		[session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
		[analyzer record];
	}else{
		[session setCategory:AVAudioSessionCategoryPlayback error:nil];
	}
	[generator play];
}

- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
	NSLog(@"inputIsAvailableChanged %d",isInputAvailable);
	[self restartAnalyzerAndGenerator:isInputAvailable];
}

- (void)beginInterruption
{
	NSLog(@"beginInterruption");
}

- (void)endInterruption
{
	NSLog(@"endInterruption");
}


+ (iNeedCaffeineAppDelegate*) getInstance
{
	return (iNeedCaffeineAppDelegate*)[UIApplication sharedApplication].delegate;
}

@end
