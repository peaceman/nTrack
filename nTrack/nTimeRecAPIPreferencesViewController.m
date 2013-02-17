//
//  nTimeRecAPIPreferencesViewController.m
//  nTrack
//
//  Created by Nico Naegele on 2/17/13.
//  Copyright (c) 2013 n2305. All rights reserved.
//

#import "nTimeRecAPIPreferencesViewController.h"
#import "AFnTimeRecAPIClient.h"

@interface nTimeRecAPIPreferencesViewController ()
- (void)saveUserInformation:(NSDictionary*)userInformation toUserDefaults:(NSUserDefaults*)userDefaults;
@end

@implementation nTimeRecAPIPreferencesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (!(self = [super initWithNibName:@"nTimeRecAPIPreferencesView" bundle:nil]))
        return nil;

    [self loadView];

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults stringForKey:@"api_secret_key"] != nil) {
        self.view = self.deviceRegistrationStateView;
    }

    return self;
}

- (IBAction)registerWithServer:(id)sender {
    NSData* jsonRegistrationData = [[self.registrationData stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    if ([jsonRegistrationData length] == 0) {
        return;
    }

    NSError* error;
    NSDictionary* userInformation = [NSJSONSerialization JSONObjectWithData:jsonRegistrationData options:nil error:&error];
    if (userInformation == nil) {
        [NSException raise:@"Can't decode jsonRegistrationData" format:@"error description %@", [error description]];
    }

    NSLog(@"user information: %@", userInformation);
    [self saveUserInformation:userInformation toUserDefaults:[NSUserDefaults standardUserDefaults]];

    [[AFnTimeRecAPIClient sharedClient] postPath:@"device/activate" parameters:[NSDictionary dictionaryWithObject:[[NSHost currentHost] localizedName] forKey:@"device_name"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.view.superview replaceSubview:self.view with:self.deviceRegistrationStateView];
        self.view = self.deviceRegistrationStateView;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Can't activate device at nTimeRec: %@", error);
    }];
}

- (void)saveUserInformation:(NSDictionary *)userInformation toUserDefaults:(NSUserDefaults *)userDefaults
{
    [userDefaults setObject:[userInformation objectForKey:@"device_id"] forKey:@"api_device_id"];
    [userDefaults setObject:[userInformation objectForKey:@"user_id"] forKey:@"api_user_id"];
    [userDefaults setObject:[userInformation objectForKey:@"secret"] forKey:@"api_secret_key"];
    [userDefaults synchronize];
}

#pragma mark - PreferencesModule protocol

- (NSString *)title
{
    return @"nTimeRec API";
}

- (NSString *)identifier
{
    return @"ntimerec-api";
}

- (NSImage *)image
{
    return [NSImage imageNamed:NSImageNameNetwork];
}

@end
