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
#import "ETSProfile.h"

@implementation ETSProfileViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  NSLocalizedString(@"Profil", nil);
    
    ETSConnection *connection = [[ETSConnection alloc] init];
    connection.request = [NSURLRequest requestForProfile];
    connection.entityName = @"Profile";
    connection.compareKey = @"permanentCode";
    connection.objectsKeyPath = @"d";
    self.connection = connection;
    self.connection.delegate = self;
    
    self.cellIdentifier = @"ProfileIdentifier";

    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        ETSAuthenticationViewController *ac = [self.storyboard instantiateAuthenticationViewController];
        ac.delegate = self;
        [self.navigationController pushViewController:ac animated:YES];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];

    fetchRequest.entity = entity;
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSProfile *profile = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    cell.textLabel.text = NSLocalizedString(@"Code permanent", nil);
    cell.detailTextLabel.text = profile.permanentCode;
}

/*
- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSProfile *profile = (ETSProfile *)managedObject;
    NSLog(@"%@", profile);
}*/

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


- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.connection.request = [NSURLRequest requestForProfile];
    [super controllerDidAuthenticate:controller];
}

@end

