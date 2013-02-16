//
//  ActiveApplicationTrackingService.h
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActiveApplicationTrackingService : NSObject
+ (ActiveApplicationTrackingService*)sharedInstance;
- (void)start;
- (void)stop;
@end
