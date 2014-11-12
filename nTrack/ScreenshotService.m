//
//  ScreenshotService.m
//  nTrack
//
//  Created by Nico Naegele on 2/4/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "ScreenshotService.h"

@interface ScreenshotService()
@property dispatch_source_t timer;
@property (nonatomic) NSDateFormatter *dateFormatter;

- (void)takeScreenshot;

- (NSString*)generateScreenshotTargetFileBasename;
- (void)ensureExistingPath:(NSString*)path;
- (NSDateFormatter*)dateFormatter;
@end

@implementation ScreenshotService

- (NSDateFormatter*)dateFormatter
{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    }

    return _dateFormatter;
}

+ (ScreenshotService*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });

    return _sharedObject;
}

#pragma mark - Service Actions

- (void)start
{
    long interval = [[NSUserDefaults standardUserDefaults] integerForKey:@"screenshot_interval"];

    self.timer = CreateDispatchTimer(interval * NSEC_PER_SEC,
                                     5ull * NSEC_PER_MSEC,
                                     dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                     ^{ [self takeScreenshot]; });
}

- (void)stop
{
    dispatch_source_cancel(self.timer);
}

- (void)takeScreenshot
{
    CGImageRef screenshot = CGDisplayCreateImage(CGMainDisplayID());
    CGImageWriteToFile(screenshot, kUTTypePNG, [self generateScreenshotTargetFileBasename]);
    CGImageRelease(screenshot);
}

#pragma mark - Filesystem Operations

- (NSString*)generateScreenshotTargetFileBasename
{
    NSDate *now = [NSDate date];
    NSString *savePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"save_path"];

    [self ensureExistingPath:savePath];
    return [NSString stringWithFormat:@"%@/%@", savePath, [self.dateFormatter stringFromDate:now]];
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

#pragma mark - Utility Functions

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

void CGImageWriteToFile(CGImageRef image, CFStringRef type, NSString *path) {
	CFMutableDictionaryRef mSaveMetaAndOpts = CFDictionaryCreateMutable(nil, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(mSaveMetaAndOpts, kCGImageDestinationLossyCompressionQuality,
						 CFBridgingRetain([NSNumber numberWithFloat:0.0]));	// set the compression quality here
    
    NSString *filenameExtension = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(type, kUTTagClassFilenameExtension));
    NSString *fullPath = [path stringByAppendingPathExtension:filenameExtension];

    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:fullPath];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, mSaveMetaAndOpts);

    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"Failed to write image to %@", path);
    }

    CFRelease(destination);
}

@end

