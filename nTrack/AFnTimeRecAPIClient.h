//
//  AFnTimeRecAPIClient.h
//  nTrack
//
//  Created by Nico Naegele on 2/17/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "AFHTTPClient.h"

@interface AFnTimeRecAPIClient : AFHTTPClient
+ (AFnTimeRecAPIClient*)sharedClient;
@end
