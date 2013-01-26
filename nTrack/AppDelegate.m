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
    self.screenshotTimer = CreateDispatchTimer(5ull * NSEC_PER_SEC, 5ull * NSEC_PER_MSEC, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ [self takeScreenshot]; });
}

- (void)stopScreenshotTimer
{
    dispatch_source_cancel(self.screenshotTimer);
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
