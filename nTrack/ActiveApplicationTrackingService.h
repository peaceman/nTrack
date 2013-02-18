//
//  ActiveApplicationTrackingService.h
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFnTimeRecAPIClient.h"

@interface ActiveApplicationTrackingService : NSObject
+ (ActiveApplicationTrackingService*)sharedInstance;
- (void)start;
- (void)stop;
- (void)receiveSystemHaltNotification:(id)notification;

@property NSString* currentActiveApplicationBundleIdentifier;
@end
