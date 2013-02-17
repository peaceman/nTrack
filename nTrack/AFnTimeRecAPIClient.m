//
//  AFnTimeRecAPIClient.m
//  nTrack
//
//  Created by Nico Naegele on 2/17/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "AFnTimeRecAPIClient.h"
#import "AFJSONRequestOperation.h"

static NSString* const kAFnTimeRecAPIBaseURLString = @"https://ntimerec.com/api/";
static NSInteger const kAFnTimeRecAPIVersion = 1;

@interface AFnTimeRecAPIClient()
@property NSString* secretKey;
@property NSInteger userId;
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
    [self setDefaultHeader:@"Accept" value:@"application/json"];

    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    self.secretKey = [standardUserDefaults stringForKey:@"api_secret_key"];
    self.userId = [standardUserDefaults integerForKey:@"api_user_id" ];

    if (self.secretKey == nil) {
        [NSException raise:@"missing api credentials" format:@"secretKey is nil"];
    }

    if (self.userId == 0) {
        [NSException raise:@"missing api credentials" format:@"userId is 0"];
    }

    return self;
}


@end
