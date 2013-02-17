//
//  AppDelegate.h
//  nTrack
//
//  Created by Nico Naegele on 1/24/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MenuController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (weak) IBOutlet MenuController *menuController;
@end
