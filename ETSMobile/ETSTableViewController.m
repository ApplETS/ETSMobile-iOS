//
//  ETSTableViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-09.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "ETSMenuViewController.h"
#import "RKDropdownAlert.h"
#import "UIColor+Styles.h"

@interface ETSTableViewController ()

@end

@implementation ETSTableViewController

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataNeedRefresh = YES;
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    self.shouldRemoveFetchedDelegate = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.shouldRemoveFetchedDelegate) self.fetchedResultsController.delegate = nil;
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];

    NSError *error;
    if (self.dataNeedRefresh) [self.synchronization synchronize:&error];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeMove: break;
        case NSFetchedResultsChangeUpdate: break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{
    if (synchronization != self.synchronization) return;
    
    if (response == ETSSynchronizationResponseAuthenticationError) {
        
        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]] || self.presentedViewController) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d’accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                ac.delegate = self;
                [self.navigationController pushViewController:ac animated:YES];
            } else {
                UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
                authenticationController.delegate = self;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
        }
    }
    else if (response == ETSSynchronizationResponseValid) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    [self.refreshControl endRefreshing];
}

- (void)synchronizationDidFinishLoadingWithErrors:(NSString *)error {
    [self.refreshControl endRefreshing];
    [RKDropdownAlert title:@"Erreur" message:error backgroundColor:[UIColor naviguationBarTintColor] textColor:[UIColor whiteColor] time:3];
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

@end
