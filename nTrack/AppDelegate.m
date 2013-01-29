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
@synthesize theItem;
@synthesize theMenu;
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

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    }

    return _dateFormatter;
}
- (IBAction)printRunningApplications:(NSMenuItem *)sender
{
    NSWorkspace *sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSLog(@"running applications: %@", [sharedWorkspace runningApplications]);
}

- (void)startActiveApplicationTracking
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(activeAppDidChange:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
}

- (void)activeAppDidChange:(NSNotification*)notification
{
    NSRunningApplication *activeApp = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];
    NSLog(@"active application: %@", activeApp);
}

- (void)startScreenshotTimer
{
    long interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"screenshot_interval"];
    self.screenshotTimer = CreateDispatchTimer(interval * NSEC_PER_SEC, 5ull * NSEC_PER_MSEC, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self takeScreenshot]; });
}

- (void)stopScreenshotTimer
{
    dispatch_source_cancel(self.screenshotTimer);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
    [appDefaults setObject:[NSNumber numberWithInt:23] forKey:@"screenshot_interval"];
    [appDefaults setObject:[NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), @"nTrack"] forKey:@"save_path"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    self.folderDropDown.selectedItem.title = [[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"save_path"]] lastPathComponent];
    
    [self activateStatusMenu];
    [self startActiveApplicationTracking];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];

    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];

    [theItem setTitle: @"nTrack"];
    [theItem setHighlightMode: YES];
    [theItem setMenu:theMenu];
}

- (void)takeScreenshot
{
    CGImageRef screenshot = CGDisplayCreateImage(CGMainDisplayID());
    CGImageWriteToFile(screenshot, [self generateScreenshotTargetFilename]);
    CGImageRelease(screenshot);
}

- (void)ensureExistingPath:(NSString*)path
{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];

    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
}

- (NSString*)generateScreenshotTargetFilename
{
    NSDate *now = [NSDate date];
    NSString *savePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"save_path"];

    [self ensureExistingPath:savePath];
    return [NSString stringWithFormat:@"%@/%@.png", savePath, [self.dateFormatter stringFromDate:now]];
}

- (IBAction)omfgWasPressed:(NSMenuItem*)sender
{
    if (sender.state == NSOnState) {
        [self stopScreenshotTimer];
        sender.state = NSOffState;
    } else {
        [self startScreenshotTimer];
        sender.state = NSOnState;
    }
}

void CGImageWriteToFile(CGImageRef image, NSString *path) {
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);

    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
    }

    CFRelease(destination);
}

dispatch_source_t CreateDispatchTimer(uint64_t interval, uint64_t leeway, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    if (timer) {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }

    return timer;
}



@end
