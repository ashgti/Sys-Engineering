//
//  RootViewController.m
//  iNeedCaffeine
//
//  Created by John Harrison on 4/4/11.
//  Copyright 2011 Auburn University. All rights reserved.
//

#import "RootViewController.h"
#import "SettingViewController.h"
#import "CharReceiver.h"
#import "iNeedCaffeineAppDelegate.h"
#include <ctype.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
    
	free(buffer); //free the buffer;
	return nil;
}

- (NSData *)AES256DecryptWithKey:(NSString *)key {
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [self length];
	
	//See the doc: For block ciphers, the output size will always be less than or 
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

@end


@implementation RootViewController

@synthesize mapView;
@synthesize segControl;
@synthesize clearButton;

@synthesize myTapRecognizer;
@synthesize myColor;

- (id)initWithCoder:(NSCoder *)aDecoder 
{
    self = [super initWithCoder:aDecoder];
    if (self){
		multiByteLength = 0;
		multiBytePos = 0;
        myColor = MKPinAnnotationColorRed;
		memset(multiBytes, 0, sizeof(multiBytes));
    }
    NSLog(@"RootViewController: Coder Init called");
    return self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [myTapRecognizer release];
	[segControl release];
	[mapView release];
    [super dealloc];
}

- (IBAction) changeMarkerType:(id) sender{
    NSLog(@"Changed Mark Type");
	switch (segControl.selectedSegmentIndex) {
		case 0:
		{
			myColor = MKPinAnnotationColorRed;
			break;
		}
		case 1:
		{
			myColor = MKPinAnnotationColorPurple;
			break;
		}
		case 2:
		{
			myColor = MKPinAnnotationColorGreen;
			break;
		}
	}
    
    NSLog(@"Color is now %d", myColor);
}

- (void) handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Hi from the tap handler with color: %d", myColor);
	if(segControl.selectedSegmentIndex == 3)
	{
		//this means 'None' is selected, nothing gets placed on the map
		return;
	}
    
    NSLog(@"Hi from the tap handler %p", self);
	
	CGPoint touchPoint = [myTapRecognizer locationInView:mapView];
	CLLocationCoordinate2D touchMapCoordinate = 
	[mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    
    char buf[200] = "";
    sprintf(buf, "%2d %+3.4lf %+3.4lf", myColor, touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    NSData *encrypted = [NSData dataWithBytes:buf length:strlen(buf)];
    NSData *cipher = [encrypted AES256EncryptWithKey:[iNeedCaffeineAppDelegate getInstance].passwd];
    NSLog(@"Encrypted: %s", [[cipher description] UTF8String]);

    memset(buf, 0, sizeof(buf));
    
    sprintf(buf, "%c%s%c", MSG_START, [[cipher description] UTF8String], MSG_END);
	NSLog(@"Printing:  %s", buf);
    NSLog(@"Regions is: %+3.4lf %+3.4lf ", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    NSLog(@"Lat/Long %+3.4lf/%+3.4lf", touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    
    
    [[iNeedCaffeineAppDelegate getInstance].generator writeBytes: buf
                                                          length: strlen(buf)];
    
    // [mapView addAnnotation:pa];
    [pa release];
}

- (IBAction) handleClearButton{
    NSLog(@"Handling Clear");
	[mapView removeAnnotations:mapView.annotations];
}

- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation:(id ) annotation {
    NSLog(@"mapView:viewForAnnotation: called");
    MKPinAnnotationView *customPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
    NSLog(@"Color is now %d", myColor);
    customPinView.pinColor = myColor;
    customPinView.animatesDrop = NO;
    customPinView.canShowCallout = YES;
    return customPinView;
}

- (void)viewWillAppear:(BOOL)animated {
    MKCoordinateRegion reg; /* Auburn Regions */
    reg.center.latitude  =  32.597290;
    reg.center.longitude = -85.496149;
    reg.span.latitudeDelta  = 1.879535;
    reg.span.longitudeDelta = 1.922111;
    
    [mapView setRegion:reg animated:FALSE];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"Testing stuff. Load Regnizer here");
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(handleSingleTap:)];
	[mapView addGestureRecognizer:recognizer];
    self.myTapRecognizer = recognizer;

    NSLog(@"view is: %@ %@", mapView, recognizer);
	[recognizer release];
	
	self.title = @"Map View";
}


- (void) receivedChar:(char)input
{
    NSLog(@"Hi from receivedChar: %c", input);
	unsigned char byte = (unsigned char)input;
	NSMutableString *newstr = [NSMutableString string];
	
	/*
	 C0-DF 2byte
	 E0-EF 3byte
	 F0-F7 4byte
	 */
	if (multiBytePos < multiByteLength) {
		multiBytes[multiBytePos++] = byte;
		if (multiBytePos == multiByteLength){
			multiBytes[multiBytePos] = 0;
			NSString *utf8 = [NSString stringWithUTF8String: multiBytes];
			if (utf8 && [utf8 length]){
				[newstr appendString:utf8];
			}else{
				int i;
				for(i=0; i<multiByteLength; i++)
					[newstr appendFormat:@"(%x)", multiBytes[i]];
			}
		}
	}
    else {
		if (0xCF <= byte && byte <= 0xDF){
			multiByteLength = 2;
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else if (0xE0 <= byte && byte <= 0xEF){
			multiByteLength = 3;
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else if (0xF0 <= byte && byte <= 0xF7){
			multiByteLength = 4;			
			multiBytePos = 0;
			multiBytes[multiBytePos++] = byte;
		}
		else {
			if(isascii(input)) {
				[newstr appendFormat:@"%c", input];
			}
            else {
				[newstr appendFormat:@"(%x)", byte];
			}
		}
	}
	
	if([newstr length] > 0){
        if ([newstr compare: @"\v"] == NSOrderedSame) {
            // end of string
            NSLog(@"Got end of string %s",  myStr);
            NSData *encrypted = [NSData dataWithBytes:myStr length:strlen(myStr)];
            NSData *plain = [encrypted AES256DecryptWithKey:[iNeedCaffeineAppDelegate getInstance].passwd];
            
            memset(myStr, 0, sizeof(myStr));
            
            sprintf(myStr, "%s\n", [[plain description] UTF8String]);
            
            MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
            CLLocationCoordinate2D touchMapCoordinate;
            
            int color;
            
            sscanf(myStr, "%d %lf %lf", &color, &touchMapCoordinate.latitude, &touchMapCoordinate.longitude);
            
            myColor = color;
            pa.coordinate = touchMapCoordinate;
            [mapView addAnnotation:pa];
            
            NSLog(@"Got: %d %lf %lf", color, touchMapCoordinate.latitude, touchMapCoordinate.longitude);
        }
        else if ([newstr compare: @"\t"] == NSOrderedSame) {
            // start of string
            memset(myStr, 0, sizeof(myStr));
            str_len = 0;
            NSLog(@"Got start of string with string = %s", myStr);
        }
        else {
            NSLog(@"middle bits");
            myStr[str_len++] = input;
        }
	}
}

@end
