//
//  MenuController.h
//  nTrack
//
//  Created by Nico Naegele on 2/3/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScreenshotService.h"
#import "ActiveApplicationTrackingService.h"

@interface MenuController : NSObject
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *takeScreenshotsItem;
@property (weak) IBOutlet NSMenuItem *trackActiveApplicationItem;
@property (weak) IBOutlet NSMenuItem *openPreferencesItem;
@property (weak) IBOutlet NSMenuItem *quitItem;
@property (strong) NSStatusItem *statusItem;

- (void)setupMenu;

- (IBAction)takeScreenshots:(id)sender;
- (IBAction)trackActiveApplication:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quit:(id)sender;

@end
