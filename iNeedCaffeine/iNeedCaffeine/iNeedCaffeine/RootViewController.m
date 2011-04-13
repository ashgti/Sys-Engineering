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


#import <Foundation/Foundation.h>

void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *NewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

@end


//
// Mapping from 6 bit pattern to ASCII character.
//
static unsigned char base64EncodeLookup[65] =
"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

//
// Definition for "masked-out" areas of the base64DecodeLookup mapping
//
#define xx 65

//
// Mapping from ASCII character to 6 bit pattern.
//
static unsigned char base64DecodeLookup[256] =
{
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 62, xx, xx, xx, 63, 
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, xx, xx, xx, xx, xx, xx, 
    xx,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, xx, xx, xx, xx, xx, 
    xx, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
    xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, xx, 
};

//
// Fundamental sizes of the binary and base64 encode/decode units in bytes
//
#define BINARY_UNIT_SIZE 3
#define BASE64_UNIT_SIZE 4

//
// NewBase64Decode
//
// Decodes the base64 ASCII string in the inputBuffer to a newly malloced
// output buffer.
//
//  inputBuffer - the source ASCII string for the decode
//	length - the length of the string or -1 (to specify strlen should be used)
//	outputLength - if not-NULL, on output will contain the decoded length
//
// returns the decoded buffer. Must be free'd by caller. Length is given by
//	outputLength.
//
void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength)
{
	if (length == -1)
	{
		length = strlen(inputBuffer);
	}
	
	size_t outputBufferSize =
    ((length+BASE64_UNIT_SIZE-1) / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE;
	unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
	
	size_t i = 0;
	size_t j = 0;
	while (i < length)
	{
		//
		// Accumulate 4 valid characters (ignore everything else)
		//
		unsigned char accumulated[BASE64_UNIT_SIZE];
		size_t accumulateIndex = 0;
		while (i < length)
		{
			unsigned char decode = base64DecodeLookup[inputBuffer[i++]];
			if (decode != xx)
			{
				accumulated[accumulateIndex] = decode;
				accumulateIndex++;
				
				if (accumulateIndex == BASE64_UNIT_SIZE)
				{
					break;
				}
			}
		}
		
		//
		// Store the 6 bits from each of the 4 characters as 3 bytes
		//
		// (Uses improved bounds checking suggested by Alexandre Colucci)
		//
		if(accumulateIndex >= 2)  
			outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);  
		if(accumulateIndex >= 3)  
			outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);  
		if(accumulateIndex >= 4)  
			outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
		j += accumulateIndex - 1;
	}
	
	if (outputLength)
	{
		*outputLength = j;
	}
	return outputBuffer;
}

//
// NewBase64Encode
//
// Encodes the arbitrary data in the inputBuffer as base64 into a newly malloced
// output buffer.
//
//  inputBuffer - the source data for the encode
//	length - the length of the input in bytes
//  separateLines - if zero, no CR/LF characters will be added. Otherwise
//		a CR/LF pair will be added every 64 encoded chars.
//	outputLength - if not-NULL, on output will contain the encoded length
//		(not including terminating 0 char)
//
// returns the encoded buffer. Must be free'd by caller. Length is given by
//	outputLength.
//
char *NewBase64Encode(
                      const void *buffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength)
{
	const unsigned char *inputBuffer = (const unsigned char *)buffer;
	
#define MAX_NUM_PADDING_CHARS 2
#define OUTPUT_LINE_LENGTH 64
#define INPUT_LINE_LENGTH ((OUTPUT_LINE_LENGTH / BASE64_UNIT_SIZE) * BINARY_UNIT_SIZE)
#define CR_LF_SIZE 2
	
	//
	// Byte accurate calculation of final buffer size
	//
	size_t outputBufferSize =
    ((length / BINARY_UNIT_SIZE)
     + ((length % BINARY_UNIT_SIZE) ? 1 : 0))
    * BASE64_UNIT_SIZE;
	if (separateLines)
	{
		outputBufferSize +=
        (outputBufferSize / OUTPUT_LINE_LENGTH) * CR_LF_SIZE;
	}
	
	//
	// Include space for a terminating zero
	//
	outputBufferSize += 1;
    
	//
	// Allocate the output buffer
	//
	char *outputBuffer = (char *)malloc(outputBufferSize);
	if (!outputBuffer)
	{
		return NULL;
	}
    
	size_t i = 0;
	size_t j = 0;
	const size_t lineLength = separateLines ? INPUT_LINE_LENGTH : length;
	size_t lineEnd = lineLength;
	
	while (true)
	{
		if (lineEnd > length)
		{
			lineEnd = length;
		}
        
		for (; i + BINARY_UNIT_SIZE - 1 < lineEnd; i += BINARY_UNIT_SIZE)
		{
			//
			// Inner loop: turn 48 bytes into 64 base64 characters
			//
			outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                                   | ((inputBuffer[i + 1] & 0xF0) >> 4)];
			outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i + 1] & 0x0F) << 2)
                                                   | ((inputBuffer[i + 2] & 0xC0) >> 6)];
			outputBuffer[j++] = base64EncodeLookup[inputBuffer[i + 2] & 0x3F];
		}
		
		if (lineEnd == length)
		{
			break;
		}
		
		//
		// Add the newline
		//
		outputBuffer[j++] = '\r';
		outputBuffer[j++] = '\n';
		lineEnd += lineLength;
	}
	
	if (i + 1 < length)
	{
		//
		// Handle the single '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[((inputBuffer[i] & 0x03) << 4)
                                               | ((inputBuffer[i + 1] & 0xF0) >> 4)];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i + 1] & 0x0F) << 2];
		outputBuffer[j++] =	'=';
	}
	else if (i < length)
	{
		//
		// Handle the double '=' case
		//
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0xFC) >> 2];
		outputBuffer[j++] = base64EncodeLookup[(inputBuffer[i] & 0x03) << 4];
		outputBuffer[j++] = '=';
		outputBuffer[j++] = '=';
	}
	outputBuffer[j] = 0;
	
	//
	// Set the output length and return the buffer
	//
	if (outputLength)
	{
		*outputLength = j;
	}
	return outputBuffer;
}

@implementation NSData (Base64)

//
// dataFromBase64String:
//
// Creates an NSData object containing the base64 decoded representation of
// the base64 string 'aString'
//
// Parameters:
//    aString - the base64 string to decode
//
// returns the autoreleased NSData representation of the base64 string
//
+ (NSData *)dataFromBase64String:(NSString *)aString
{
	NSData *data = [aString dataUsingEncoding:NSASCIIStringEncoding];
	size_t outputLength;
	void *outputBuffer = NewBase64Decode([data bytes], [data length], &outputLength);
	NSData *result = [NSData dataWithBytes:outputBuffer length:outputLength];
	free(outputBuffer);
	return result;
}

//
// base64EncodedString
//
// Creates an NSString object that contains the base 64 encoding of the
// receiver's data. Lines are broken at 64 characters long.
//
// returns an autoreleased NSString being the base 64 representation of the
//	receiver.
//
- (NSString *)base64EncodedString
{
	size_t outputLength;
	char *outputBuffer =
    NewBase64Encode([self bytes], [self length], true, &outputLength);
	
	NSString *result =
    [[[NSString alloc]
      initWithBytes:outputBuffer
      length:outputLength
      encoding:NSASCIIStringEncoding]
     autorelease];
	free(outputBuffer);
	return result;
}

@end



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
    
    memset(buf, 0, sizeof(buf));
    
    sprintf(buf, "%c%s%c", MSG_START, [[cipher base64EncodedString] UTF8String], MSG_END);
	NSLog(@"Printing:  %s", buf);
    NSLog(@"Regions is: %+3.4lf %+3.4lf ", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
    NSLog(@"Lat/Long %+3.4lf/%+3.4lf", touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    
    [[iNeedCaffeineAppDelegate getInstance].generator writeBytes: buf
                                                          length: strlen(buf)];
    
    // [mapView addAnnotation:pa];
    [pa release];
    //[encrypted release];
    //[cipher release];
}

- (IBAction) handleClearButton {
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
            NSString *encrypted_text = [[NSString alloc] initWithUTF8String:myStr];
            NSData *encrypted = [NSData dataFromBase64String:encrypted_text];
            NSData *plain = [encrypted AES256DecryptWithKey:[iNeedCaffeineAppDelegate getInstance].passwd];
            
            memset(myStr, 0, sizeof(myStr));
            
            [plain getBytes: myStr length: [plain length]];
            
            NSLog(@"Decrypted to: %s %d", myStr, [plain length]);
            
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
