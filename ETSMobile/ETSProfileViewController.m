//
//  ETSProfileViewController.m
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSProfileViewController.h"
#import "NSURLRequest+API.h"
<<<<<<< HEAD

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
=======
#import "UIStoryboard+ViewController.h"
#import "ETSProfile.h"

@implementation ETSProfileViewController

@synthesize fetchedResultsController = _fetchedResultsController;
>>>>>>> 4ad2dbd58f0e7655d903c101132d96cc02f424b3

- (void)viewDidLoad
{
    [super viewDidLoad];
    
<<<<<<< HEAD
    self.cellIdentifier = @"ProfileIdentifier";
    
    ETSConnection *connection = [[ETSConnection alloc] init];
    connection.request = [NSURLRequest requestForProfile];
    connection.entityName = @"Profile";
    connection.compareKey = @"lastName";
    connection.objectsKeyPath = @"d.liste";

    self.connection = connection;
    self.connection.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.maximumFractionDigits = 1;
    self.formatter.minimumFractionDigits = 1;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Profil";
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 10;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
=======
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
>>>>>>> 4ad2dbd58f0e7655d903c101132d96cc02f424b3
    }
    
    return _fetchedResultsController;
}

<<<<<<< HEAD
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count] + 1;
}
=======
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
>>>>>>> 4ad2dbd58f0e7655d903c101132d96cc02f424b3

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
    return [sectionInfo numberOfObjects];
}

<<<<<<< HEAD
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Informations personnelles", nil);
    else if (section == 1)  return NSLocalizedString(@"Programme", nil);
    return nil;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Prénom", nil);
        cell.detailTextLabel.text = self.profile.firstName;
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Nom de famille", nil);
        cell.detailTextLabel.text = self.profile.lastName;
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Code permanent", nil);
        cell.detailTextLabel.text = self.profile.permanentCode;
    }
    else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Balance", nil);
        cell.detailTextLabel.text = [self.formatter stringFromNumber:self.profile.balance];
    }
}

- (void)connection:(ETSConnection *)connection didReceiveDictionary:(NSDictionary *)dictionary
{
    NSDictionary *results = dictionary[@"d"];
    self.profile.firstName      = results[@"nom"];
    self.profile.lastName       = results[@"prenom"];
    self.profile.permanentCode  = results[@"codePerm"];
    self.profile.balance        = [NSDecimalNumber decimalNumberWithString:results[@"soldeTotal"]];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    if (newIndexPath) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];
    }
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}

- (void)connectionDidFinishLoading:(ETSConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    for (NSInteger i = 0; i < rows; i++) {
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}
=======

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.connection.request = [NSURLRequest requestForProfile];
    [super controllerDidAuthenticate:controller];
}

@end
>>>>>>> 4ad2dbd58f0e7655d903c101132d96cc02f424b3

@end
