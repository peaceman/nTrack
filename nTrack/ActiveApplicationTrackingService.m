//
//  ActiveApplicationTrackingService.m
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "ActiveApplicationTrackingService.h"

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
}

- (void)logCurrentAppBundleIdentifier:(NSString*)bundleIdentifier
{
    NSLog(@"current active application: %@", bundleIdentifier);
}
@end
