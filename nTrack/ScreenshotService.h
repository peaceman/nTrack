//
//  ScreenshotService.h
//  nTrack
//
//  Created by Nico Naegele on 2/4/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenshotService : NSObject
+ (ScreenshotService*)sharedInstance;
- (void)start;
- (void)stop;
@end
