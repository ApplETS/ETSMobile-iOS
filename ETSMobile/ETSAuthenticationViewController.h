//
//  ETSAuthenticationViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-03.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSSynchronization.h"

@protocol ETSAuthenticationViewControllerDelegate;

@interface ETSAuthenticationViewController : UIViewController

+ (ETSSynchronizationResponse)validateJSONResponse:(NSDictionary *)response;
- (IBAction)authenticate:(id)sender;
- (IBAction)cancel:(id)sender;
+ (NSString *)passwordInKeychain;
+ (NSString *)usernameInKeychain;
+ (void)resetKeychain;

@property (weak, nonatomic) id<ETSAuthenticationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@protocol ETSAuthenticationViewControllerDelegate
- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller;
@end
