//
//  PreferencesWindowController.h
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModule.h"

@interface PreferencesWindowController : NSWindowController <NSToolbarDelegate>	
- (void)setModules:(NSArray*)newModules;
- (void)setupModules;
+ (PreferencesWindowController*)sharedInstance;
@end
