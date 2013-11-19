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
#import "ETSProfileRow.h"
#import "NSURLRequest+API.h"
#import "UIStoryboard+ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ETSProfileViewController ()
    @property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ETSProfileViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  NSLocalizedString(@"Profil", nil);
    
    self.cellIdentifier = @"ProfileIdentifier";
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

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchLimit = 1;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:NO]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"lastName" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSProfile *profile = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ETSProfileRow *profileRow = (ETSProfileRow *)cell;
    NSLog(@"%@", profileRow);
    NSLog(@"%@", profile);
    profileRow.keyLabel.text = @"Nom :";
    profileRow.valueLabel.text = profile.lastName;
}

- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSProfile *profile = (ETSProfile *)managedObject;
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.request = [NSURLRequest requestForProfile];
    [super controllerDidAuthenticate:controller];
}

@end

