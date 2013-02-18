//
//  ActiveApplicationTrackingService.m
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "ActiveApplicationTrackingService.h"
#import "AFHTTPRequestOperation.h"

@implementation ActiveApplicationTrackingService
+ (ActiveApplicationTrackingService*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

- (id)init
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSystemHaltNotification:) name:NSWorkspaceWillSleepNotification object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(receiveSystemHaltNotification:) name:NSWorkspaceWillPowerOffNotification object:nil];

    return self;
}

- (void)receiveSystemHaltNotification:(id)notification
{
    [[AFnTimeRecAPIClient sharedClient] postPath:@"active-application" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"stop", @"type", self.currentActiveApplicationBundleIdentifier, @"application_identifier", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sent stop active-application event to ntimerec");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"api-call failed: %@", error);
    }];

    [[AFnTimeRecAPIClient sharedClient].lastOperation waitUntilFinished];
}

#pragma mark - Service Actions

- (void)start
{
    for (NSRunningApplication* runningApplication in [[NSWorkspace sharedWorkspace] runningApplications]) {
        if (runningApplication.isActive) {
            [self logCurrentAppBundleIdentifier:runningApplication.bundleIdentifier];
            break;
        }
    }

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(activeAppDidChange:) name: NSWorkspaceDidActivateApplicationNotification object:nil];
}

- (void)stop
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)activeAppDidChange:(NSNotification*)notification
{
    NSRunningApplication* activeApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    [self logCurrentAppBundleIdentifier:activeApp.bundleIdentifier];
    self.currentActiveApplicationBundleIdentifier = activeApp.bundleIdentifier;
}

- (void)logCurrentAppBundleIdentifier:(NSString*)bundleIdentifier
{
    NSLog(@"current active application: %@", bundleIdentifier);
    [[AFnTimeRecAPIClient sharedClient] postPath:@"active-application" parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"change", @"type", bundleIdentifier, @"application_identifier", nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"sent active-application event to ntimerec");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"api-call failed: %@", error);
    }];
}
@end
