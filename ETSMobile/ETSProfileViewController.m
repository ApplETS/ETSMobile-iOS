//
//  ETSProfileViewController.m
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSProfileViewController.h"
#import "NSURLRequest+API.h"

@interface ETSProfileViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, assign) BOOL hadResults;
@end

@implementation ETSProfileViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)startRefresh:(id)sender
{
    [self.connection loadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cellIdentifier = @"ProfileIdentifier";
    
    ETSConnection *connection = [[ETSConnection alloc] init];
    connection.request = [NSURLRequest requestForProfile];
    connection.entityName = @"Profile";
    connection.compareKey = @"lastName";
    connection.objectsKeyPath = @"d";

    self.connection = connection;
    self.connection.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.maximumFractionDigits = 2;
    self.formatter.minimumFractionDigits = 2;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Profil";
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 4;
    //FIXME : à corriger lorsque l'on aura les infos sur la section Programme
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Informations personnelles", nil);
    else if (section == 1)  return NSLocalizedString(@"Programme", nil);
    return nil;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //FIXME : à corriger lorsque l'on aura les infos sur la section Programme
    if (indexPath.section == 1) return;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    ETSProfile *profile = nil;
    if ([self.fetchedResultsController.fetchedObjects count] > 0) profile = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Prénom", nil);
        cell.detailTextLabel.text = profile.firstName;
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Nom de famille", nil);
        cell.detailTextLabel.text = profile.lastName;
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Code permanent", nil);
        cell.detailTextLabel.text = profile.permanentCode;
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Balance", nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ $", [self.formatter stringFromNumber:profile.balance]];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    //FIXME : à corriger lorsque l'on aura les infos sur la section Programme
    for (NSInteger i = 0; i < 4; i++) {
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.connection.request = [NSURLRequest requestForProfile];
    [super controllerDidAuthenticate:controller];
}

@end
