//
//  AppDelegate.m
//  nTrack
//
//  Created by Nico Naegele on 1/24/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) dispatch_source_t screenshotTimer;
@property (weak) IBOutlet NSPopUpButtonCell *folderDropDown;
@end

@implementation AppDelegate
@synthesize dateFormatter = _dateFormatter;

- (IBAction)openSavePathFileDialog:(NSMenuItem *)sender
{
    [self.folderDropDown selectItemAtIndex:0];
    NSOpenPanel* openDialog = [NSOpenPanel openPanel];
    openDialog.canChooseDirectories = YES;
    openDialog.canChooseFiles = NO;
    openDialog.allowsMultipleSelection = NO;

    if ([openDialog runModal] == NSOKButton) {
        NSURL *selectedFolder = openDialog.URL;
        self.folderDropDown.selectedItem.title = selectedFolder.lastPathComponent;

        [[NSUserDefaults standardUserDefaults] setObject:selectedFolder.path forKey:@"save_path"];

        NSLog(@"user selected folder: %@", selectedFolder.path);
    }
}

- (void)startActiveApplicationTracking
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(activeAppDidChange:)
                                                               name:NSWorkspaceDidActivateApplicationNotification
                                                             object:nil];
}

- (void)stopActiveApplicationTracking
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)activeAppDidChange:(NSNotification*)notification
{
    NSRunningApplication *activeApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    NSLog(@"active application: %@", activeApp);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
    [appDefaults setObject:[NSNumber numberWithInt:23] forKey:@"screenshot_interval"];
    [appDefaults setObject:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"nTrack"] forKey:@"save_path"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    self.folderDropDown.selectedItem.title = [[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"save_path"]] lastPathComponent];

    [self.menuController setupMenu];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)trackActiveApplicationWasPressed:(NSMenuItem *)sender
{
    if (sender.state == NSOnState) {
        [self stopActiveApplicationTracking];
        sender.state = NSOffState;
    } else {
        [self startActiveApplicationTracking];
        sender.state = NSOnState;
    }
}





@end
