//
//  AppDelegate.m
//  nTrack
//
//  Created by Nico Naegele on 1/24/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "AppDelegate.h"
#import "AFnTimeRecAPIClient.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
    [appDefaults setObject:[NSNumber numberWithInt:30] forKey:@"screenshot_interval"];
    [appDefaults setObject:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"nTrack"] forKey:@"save_path"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    [self.menuController setupMenu];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
