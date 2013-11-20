//
//  ETSTableViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-09.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "MFSideMenu.h"
#import "UIStoryboard+ViewController.h"

@interface ETSTableViewController ()

@end

@implementation ETSTableViewController

- (void)startRefresh:(id)sender
{
    [self.connection loadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataNeedRefresh = YES;
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];

    if (self.dataNeedRefresh) [self.connection loadData];

    if ([[self.navigationController viewControllers] count] > 1)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController | MFSideMenuPanModeSideMenu;
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


- (void)connection:(ETSConnection *)connection didReceiveResponse:(ETSConnectionResponse)response
{
    
    if (response == ETSConnectionResponseAuthenticationError) {
        
        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d'accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        else {
            ETSAuthenticationViewController *ac = [self.storyboard instantiateAuthenticationViewController];
            ac.delegate = self;
            [self.navigationController pushViewController:ac animated:YES];
        }
    }
    else if (response == ETSConnectionResponseValid) {
        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)connectionDidFinishLoading:(ETSConnection *)connection
{
    [self.refreshControl endRefreshing];
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    [self.connection loadData];
}

@end
