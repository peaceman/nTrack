//
//  GeneralPreferencesViewController.h
//  nTrack
//
//  Created by Nico Naegele on 2/14/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesModule.h"

@interface GeneralPreferencesViewController : NSViewController <PreferencesModule>

@property (weak) IBOutlet NSPopUpButtonCell *folderDropDown;
@end
