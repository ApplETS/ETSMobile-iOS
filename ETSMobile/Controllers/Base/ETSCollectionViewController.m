//
//  ETSCollectionViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCollectionViewController.h"
#import "ETSMenuViewController.h"

@interface ETSCollectionViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation ETSCollectionViewController

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([ETSAuthenticationViewController passwordInKeychain] && [ETSAuthenticationViewController usernameInKeychain]) {
        [self startRefresh:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    [super viewWillDisappear:animated];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{
    if (response == ETSSynchronizationResponseAuthenticationError) {
        
    if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]] || self.presentedViewController) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d'accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
    }
    else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            ETSAuthenticationViewController *authenticationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            authenticationController.delegate = self;
            [self.navigationController pushViewController:authenticationController animated:NO];
        } else {
            ETSAuthenticationViewController *authenticationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            authenticationController.delegate = self;
            authenticationController.modalPresentationStyle = UIModalPresentationFormSheet;
            authenticationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController presentViewController:authenticationController animated:NO completion:nil];
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

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    [self.refreshControl endRefreshing];
}

@end
