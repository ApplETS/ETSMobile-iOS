//
//  ETSAuthenticationViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-03.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ETSAuthenticationViewControllerDelegate;

@interface ETSAuthenticationViewController : UIViewController
@property (weak, nonatomic) id<ETSAuthenticationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
- (IBAction)authenticate:(id)sender;
+ (NSString *)passwordInKeychain;
+ (NSString *)usernameInKeychain;
+ (void)resetKeychain;
@end

@protocol ETSAuthenticationViewControllerDelegate
- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller;
@end
