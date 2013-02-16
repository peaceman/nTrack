//
//  MenuController.m
//  nTrack
//
//  Created by Nico Naegele on 2/3/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "MenuController.h"
#import "PreferencesWindowController.h"

@implementation MenuController

- (void)setupMenu
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    [self.statusItem setTitle:@"nTrack"];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setMenu:self.statusMenu];
}

- (IBAction)takeScreenshots:(NSMenuItem*)sender
{
    if (sender.state == NSOffState) {
        [[ScreenshotService sharedInstance] start];
        sender.state = NSOnState;
    } else {
        [[ScreenshotService sharedInstance] stop];
        sender.state = NSOffState;
    }
}

- (IBAction)trackActiveApplication:(NSMenuItem*)sender
{
    if (sender.state == NSOffState) {
        [[ActiveApplicationTrackingService sharedInstance] start];
        sender.state = NSOnState;
    } else {
        [[ActiveApplicationTrackingService sharedInstance] stop];
        sender.state = NSOffState;
    }
}

- (IBAction)openPreferences:(id)sender
{
    PreferencesWindowController* prefController = [PreferencesWindowController sharedInstance];
    [prefController.window center];
    [prefController.window makeKeyAndOrderFront:self];
    [prefController.window setOrderedIndex:0];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)quit:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}
@end
