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
@property (nonatomic) NSTimer* screenshotTimer;
@end

@implementation AppDelegate
@synthesize theItem;
@synthesize theMenu;
@synthesize dateFormatter = _dateFormatter;

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    }

    return _dateFormatter;
}

- (void)startScreenshotTimer
{
    if (self.screenshotTimer == nil) {
        self.screenshotTimer = [NSTimer timerWithTimeInterval:10.0 target:self selector:@selector(takeScreenshot) userInfo:nil repeats:YES];
    }

    NSRunLoop* runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.screenshotTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopScreenshotTimer
{
    if (self.screenshotTimer || [self.screenshotTimer isValid]) {
        [self.screenshotTimer invalidate];
        self.screenshotTimer = nil;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self activateStatusMenu];
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

- (NSString*)generateScreenshotTargetFilename
{
    NSDate *now = [NSDate date];
    return [NSString stringWithFormat:@"%@/%@.png", @"/Users/peaceman/Desktop", [self.dateFormatter stringFromDate:now]];
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

@end
