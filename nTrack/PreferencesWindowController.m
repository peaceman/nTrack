//
//  PreferencesWindowController.m
//  nTrack
//
//  Created by Nico Naegele on 2/13/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "GeneralPreferencesViewController.h"

@interface PreferencesWindowController ()
@property (nonatomic) NSArray* modules;
@property id<PreferencesModule> currentModule;
@end

@implementation PreferencesWindowController

+ (PreferencesWindowController*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;

    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        [_sharedObject setupModules];
    });

    return _sharedObject;
}

- (id)init
{
    if (!(self = [super init]))
        return nil;

    NSWindow *prefsWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 300, 200)
                                                        styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                          backing:NSBackingStoreBuffered defer:YES];
    prefsWindow.showsToolbarButton = NO;
    self.window = prefsWindow;
    [self createToolbar];
    return self;
}

- (void)setupModules
{
    NSArray* modules = [NSArray arrayWithObjects:
                        [[GeneralPreferencesViewController alloc] init],
                        nil];

    self.modules = modules;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)setModules:(NSArray *)newModules
{
    if (newModules == _modules) {
        return;
    }

    if (_modules) {
        _modules = nil;
    }

    if (!newModules) {
        return;
    }

    _modules = newModules;
    NSToolbar *toolbar = self.window.toolbar;
    if (toolbar) {
        NSInteger index = toolbar.items.count - 1;

        while (index > 1) {
            [toolbar removeItemAtIndex:index--];
        }

        for (id<PreferencesModule> module in _modules) {
            [toolbar insertItemWithItemIdentifier:module.identifier atIndex:toolbar.items.count];
        }
    }

    if (_modules.count) {
        [self changeToModule:[_modules objectAtIndex:0]];
    }
}

#pragma mark - Private helpers

- (void)createToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];

    [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [toolbar setAllowsUserCustomization:NO];
    [toolbar setDelegate:self];
    [toolbar setAutosavesConfiguration:NO];

    [self.window setToolbar:toolbar];
}

- (id<PreferencesModule>)moduleForIdentifier:(NSString *)identifier
{
    for (id<PreferencesModule> module in _modules) {
        if ([module.identifier isEqualToString:identifier])
            return module;
    }

    return nil;
}

- (void)selectModule:(NSToolbarItem *)sender {
    if (![sender isKindOfClass:[NSToolbarItem class]])
        return;

    id<PreferencesModule> module = [self moduleForIdentifier:sender.itemIdentifier];
    if (!module)
        return;

    [self changeToModule:module];
}

- (void)changeToModule:(id<PreferencesModule>)module
{
    [self.currentModule.view removeFromSuperview];

    // The view which will be displayed
    NSView *newView = [module view];

    // Resize the window
    // Be sure to keep the top-left corner stationary
    NSRect newWindowFrame = [self.window frameRectForContentRect:newView.frame];
    newWindowFrame.origin = self.window.frame.origin;
    newWindowFrame.origin.y -= newWindowFrame.size.height - self.window.frame.size.height;
    [self.window setFrame:newWindowFrame display:YES animate:YES];

    [[self.window toolbar] setSelectedItemIdentifier:module.identifier];
    [self.window setTitle:module.title];

    // Call the optional protocol method if the module implements it
    if ([(NSObject *)module respondsToSelector:@selector(willBeDisplayed)])
        [module willBeDisplayed];

    // Show the view
    _currentModule = module;
    [[self.window contentView] addSubview:self.currentModule.view];

    // Autosave the selection
    [[NSUserDefaults standardUserDefaults] setObject:module.identifier forKey:@"PreferencesWindowSelection"];
}

#pragma mark - NSToolbarDelegate protocol

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    NSMutableArray *identifiers = [NSMutableArray array];

    for (id<PreferencesModule> module in _modules)
        [identifiers addObject:module.identifier];

    return identifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return nil;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    id<PreferencesModule> module = [self moduleForIdentifier:itemIdentifier];

    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    if (!module)
        return item;

    // Set the attributes of the item
    [item setLabel:module.title];
    [item setImage:module.image];
    [item setTarget:self];
    [item setAction:@selector(selectModule:)];

    return item;
}


@end
