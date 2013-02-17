//
//  AFnTimeRecAPIClient.m
//  nTrack
//
//  Created by Nico Naegele on 2/17/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "AFnTimeRecAPIClient.h"
#import "AFJSONRequestOperation.h"
#import <CommonCrypto/CommonHMAC.h>

static NSString* const kAFnTimeRecAPIBaseURLString = @"https://ntimerec.com/api/";
static NSInteger const kAFnTimeRecAPIVersion = 1;

@interface AFnTimeRecAPIClient()
@property NSString* secretKey;
@property NSInteger userId;
@property NSInteger deviceId;

- (NSString*)buildHmacForRequest:(NSURLRequest*)request;
@end

@implementation AFnTimeRecAPIClient
+ (AFnTimeRecAPIClient*)sharedClient
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAFnTimeRecAPIBaseURLString]];
    });

    return _sharedObject;
}

- (id)initWithBaseURL:(NSURL*)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }

    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.secretKey = [standardUserDefaults stringForKey:@"api_secret_key"];
    self.userId = [standardUserDefaults integerForKey:@"api_user_id" ];
    self.deviceId = [standardUserDefaults integerForKey:@"api_device_id"];

    if (self.secretKey == nil) {
        [NSException raise:@"missing api credentials" format:@"secretKey is nil"];
    }

    if (self.userId == 0) {
        [NSException raise:@"missing api credentials" format:@"userId is 0"];
    }

    if (self.deviceId == 0) {
        [NSException raise:@"missing api credentials" format:@"deviceId is 0"];
    }

    [self setDefaultHeader:@"userid" value:[NSString stringWithFormat:@"%ld", (long)self.userId]];
    [self setDefaultHeader:@"deviceid" value:[NSString stringWithFormat:@"%ld", (long)self.deviceId]];
    [self setDefaultHeader:@"apiversion" value:[NSString stringWithFormat:@"%ld", (long)kAFnTimeRecAPIVersion]];
    
    return self;
}

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation {
    NSMutableURLRequest* request = (NSMutableURLRequest*)operation.request;

    NSDate* now = [NSDate date];
    NSTimeInterval nowUnix = [now timeIntervalSince1970];
    NSInteger nowUnixInt = nowUnix;
    [request setValue:[NSString stringWithFormat:@"%ld", (long)nowUnixInt] forHTTPHeaderField:@"timestamp"];
    [request setValue:[self buildHmacForRequest:request] forHTTPHeaderField:@"hash"];

    [super enqueueHTTPRequestOperation:operation];
}

- (NSString*)buildHmacForRequest:(NSURLRequest*)request
{
    NSMutableString *toReturn = [[NSMutableString alloc] init];
    [toReturn appendString:[request valueForHTTPHeaderField:@"timestamp"]];
    [toReturn appendString:[request HTTPMethod]];
    [toReturn appendString:[[request URL] path]];

    if (![[request HTTPMethod] isEqual:@"GET"]) {
        NSString *httpBody = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        [toReturn appendString:httpBody];
    }

    [toReturn setString:[toReturn lowercaseString]];
    NSLog(@"contentToHash: %@", toReturn);

    const char *cKey = [self.secretKey UTF8String];
    const char *cData = [toReturn cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSMutableString *string = [NSMutableString stringWithCapacity:sizeof(cHMAC)*2];
    for (NSInteger idx = 0; idx < sizeof(cHMAC); ++idx) {
        [string appendFormat:@"%02x", cHMAC[idx]];
    }

    return string;
}



@end
