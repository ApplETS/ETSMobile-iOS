//
//  ETSCollectionViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCollectionViewController.h"
#import "UIStoryboard+ViewController.h"

@interface ETSCollectionViewController ()

@end

@implementation ETSCollectionViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.connection loadDataWithRequest:self.request entityName:self.entityName forObjectsKeyPath:self.objectsKeyPath compareKey:self.compareKey];
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


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
/*
    switch(type) {
        case NSFetchedResultsChangeInsert:
            NSLog(@"%ld, %ld", (long)newIndexPath.section, (long)newIndexPath.row);
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.collectionView cellForItemAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            break;
    }
 */
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
#warning Ajouter les animations.
    [self.collectionView reloadData];
}

- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
}

- (void)connection:(ETSConnection *)connection didReveiveResponse:(ETSConnectionResponse)response
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

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    [self.connection loadDataWithRequest:self.request entityName:self.entityName forObjectsKeyPath:self.objectsKeyPath compareKey:self.compareKey];
}


@end
