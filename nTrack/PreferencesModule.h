//
//  PreferencesModule.h
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PreferencesModule <NSObject>
@required
- (NSString *)title;
- (NSString *)identifier;
- (NSImage *)image;
- (NSView *)view;

@optional
- (void)willBeDisplayed;
@end
