//
//  ETSProfileViewController.m
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSProfileViewController.h"
#import "ETSProfile.h"
#import "ETSAuthenticationViewController.h"
#import "NSURLRequest+API.h"
#import "UIStoryboard+ViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ETSProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  NSLocalizedString(@"Profil", nil);
    
    self.connection = nil;
    self.request = [NSURLRequest requestForProfile];
    self.entityName = @"Profile";

    ETSConnection *connection = [[ETSConnection alloc] init];
    self.connection = connection;
    self.connection.delegate = self;
    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        ETSAuthenticationViewController *ac = [self.storyboard instantiateAuthenticationViewController];
        ac.delegate = self;
        [self.navigationController pushViewController:ac animated:YES];
    }
}

- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSProfile *profile = (ETSProfile *)managedObject;
    NSLog(@"%@", profile);
}

//- (void)connection:(ETSConnection *)connection didReveiveResponse:(ETSConnectionResponse)response
//{
//    
//    if (response == ETSConnectionResponseAuthenticationError) {
//        
//        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
//            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d'accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//            [av show];
//        }
//        else {
//            ETSAuthenticationViewController *ac = [self.storyboard instantiateAuthenticationViewController];
//            ac.delegate = self;
//            [self.navigationController pushViewController:ac animated:YES];
//        }
//    }
//    else if (response == ETSConnectionResponseValid) {
//        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
//}
//
//- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
//{
//    self.request = [NSURLRequest requestForProfile];
//    [self.connection loadDataWithRequest:self.request entityName:self.entityName forObjectsKeyPath:@"" compareKey:@""];
//}

@end

