//
//  ETSProfileViewController.m
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSProfileViewController.h"
#import "NSURLRequest+API.h"
#import "MFSideMenu.h"

@interface ETSProfileViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, assign) BOOL hadResults;
@end

@implementation ETSProfileViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.cellIdentifier = @"ProfileIdentifier";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForProfile];
    synchronization.entityName = @"Profile";
    synchronization.compareKey = @"permanentCode";
    synchronization.objectsKeyPath = @"d";

    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.groupingSeparator = @" ";
    self.formatter.groupingSize = 3;
    self.formatter.usesGroupingSeparator = YES;
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];
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
    if ([self.fetchedResultsController.fetchedObjects count] > 0) profile = self.fetchedResultsController.fetchedObjects[0];
    
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
        if ([self.formatter stringFromNumber:profile.balance]) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ $", [self.formatter stringFromNumber:profile.balance]];
        } else {
            cell.detailTextLabel.text = @"";
        }
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
    self.synchronization.request = [NSURLRequest requestForProfile];
    [super controllerDidAuthenticate:controller];
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return [ETSAuthenticationViewController validateJSONResponse:response];
}

@end
