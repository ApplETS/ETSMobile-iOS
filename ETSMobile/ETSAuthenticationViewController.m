//
//  ETSAuthenticationViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-03.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSAuthenticationViewController.h"
#import "KeychainItemWrapper.h"
#import "ETSAppDelegate.h"
#import "MSDynamicsDrawerViewController.h"

#import <Crashlytics/Crashlytics.h>

NSString * const kKeychainId = @"ApplETS";

@interface ETSAuthenticationViewController ()

@end

@implementation ETSAuthenticationViewController

- (IBAction)panLeftMenu:(id)sender
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = ((ETSAppDelegate *)[[UIApplication sharedApplication] delegate]).dynamicsDrawerViewController;
    [dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen animated:YES allowUserInterruption:YES completion:^{}];
}

+ (ETSSynchronizationResponse) validateJSONResponse:(NSDictionary *)response
{
    id apiError = [response valueForKeyPath:@"d.erreur"];
    
    if ([apiError isKindOfClass:[NSString class]] && [apiError isEqualToString:@"Code d'accès ou mot de passe invalide"]) {
        [Answers logSignUpWithMethod:@"ETSAuth" success:@NO customAttributes:@{}];
        return ETSSynchronizationResponseAuthenticationError;
    } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] == 0) {
        [Answers logSignUpWithMethod:@"ETSAuth" success:@NO customAttributes:@{}];
        return ETSSynchronizationResponseValid;
    } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] > 0) {
        [Answers logSignUpWithMethod:@"ETSAuth" success:@NO customAttributes:@{}];
        return ETSSynchronizationResponseUnknownError;
    }
    
    [Answers logSignUpWithMethod:@"ETSAuth" success:@YES customAttributes:@{}];
    return ETSSynchronizationResponseValid;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone animated:animated];
    
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = ((ETSAppDelegate *)[[UIApplication sharedApplication] delegate]).dynamicsDrawerViewController;
    [dynamicsDrawerViewController setPaneDragRevealEnabled:YES forDirection:MSDynamicsDrawerDirectionLeft];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.usernameTextField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else {
        if ([self.usernameTextField.text length] == 0) [self.usernameTextField becomeFirstResponder];
        else {
            [self authenticate:nil];
        }
    }
    return YES;
}

- (IBAction)authenticate:(id)sender
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"ApplETS" accessGroup:nil];
    [keychainItem setObject:self.passwordTextField.text forKey:(__bridge id)(kSecValueData)];
    [keychainItem setObject:self.usernameTextField.text forKey:(__bridge id)(kSecAttrAccount)];
    
    [self.delegate controllerDidAuthenticate:self];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (NSString *)passwordInKeychain
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainId accessGroup:nil];
    NSString *password = [keychainItem objectForKey:(__bridge id)(kSecValueData)];
    if ([password length] <= 0) password = nil;
    return password;
    
}

+ (NSString *)usernameInKeychain
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainId accessGroup:nil];
    NSString *username = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    if ([username length] <= 0) username = nil;
    return username;
}

+ (void)resetKeychain
{
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainId accessGroup:nil];
    [keychainItem resetKeychainItem];
}

@end
