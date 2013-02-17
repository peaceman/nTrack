//
//  nTimeRecAPIPreferencesViewController.h
//  nTrack
//
//  Created by Nico Naegele on 2/17/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModule.h"

@interface nTimeRecAPIPreferencesViewController : NSViewController<PreferencesModule>
@property (strong) IBOutlet NSView *registerDeviceView;
@property (strong) IBOutlet NSView *deviceRegistrationStateView;
@property (weak) IBOutlet NSTextField *registrationData;

@end
