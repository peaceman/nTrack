//
//  GeneralPreferencesViewController.m
//  nTrack
//
//  Created by Nico Naegele on 2/14/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "GeneralPreferencesViewController.h"

@interface GeneralPreferencesViewController ()

@end

@implementation GeneralPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (void)willBeDisplayed
{
    self.folderDropDown.selectedItem.title = [[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"save_path"]] lastPathComponent];
}

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

#pragma mark - GSPreferencesModule protocol

- (NSString *)title
{
    return @"General";
}

- (NSString *)identifier
{
    return @"general";
}

- (NSImage *)image
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

@end
