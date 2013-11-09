//
//  ETSAuthenticationViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-03.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSAuthenticationViewController.h"
#import "KeychainItemWrapper.h"

NSString * const kKeychainId = @"ApplETS";

@interface ETSAuthenticationViewController ()

@end

@implementation ETSAuthenticationViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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
        [self.passwordTextField resignFirstResponder];
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
