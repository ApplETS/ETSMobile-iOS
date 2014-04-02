//
//  ETSCollectionViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//
//  La mise à jour avec le NSFetchedResultsController est inspirée de
//  Aleksandar Vacić on 26.9.13.
//  https://github.com/radianttap/UICollectionView-NSFetchedResultsController
//

#import "ETSCollectionViewController.h"
#import "UIStoryboard+ViewController.h"
#import "MFSideMenu.h"

@interface ETSCollectionViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
//@property (strong, nonatomic) NSBlockOperation *collectionViewBlockOperation;
//@property (nonatomic) BOOL shouldReloadCollectionView;
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
    
   // self.collectionViewBlockOperation = [NSBlockOperation new];
   // self.shouldReloadCollectionView = NO;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    [self startRefresh:nil];
    
    if ([[self.navigationController viewControllers] count] > 1)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController | MFSideMenuPanModeSideMenu;
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

/*
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if (self.collectionViewBlockOperation.isExecuting) {
		self.shouldReloadCollectionView = YES;
		return;
	}
	
	if (self.collectionViewBlockOperation.isFinished)
		self.collectionViewBlockOperation = nil;
	
    __weak UICollectionView *collectionView = self.collectionView;
	switch(type) {
        case NSFetchedResultsChangeInsert: {
            [self.collectionViewBlockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [self.collectionViewBlockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.collectionViewBlockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.collectionViewBlockOperation.isExecuting) {
		self.shouldReloadCollectionView = YES;
		return;
	}
	
	if (self.collectionViewBlockOperation.isFinished)
		self.collectionViewBlockOperation = nil;
    
    __weak UICollectionView *collectionView = self.collectionView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:newIndexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.collectionViewBlockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == indexPath.item+1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.collectionViewBlockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.collectionViewBlockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.collectionViewBlockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if (!self) return;
	
	if (self.collectionView.window == nil) {
		//	if collection view is not currently visible, then just reload data.
		//	this prevents all sorts of crazy UICV crashes
		self.collectionViewBlockOperation = nil;
		self.shouldReloadCollectionView = NO;
		[self.collectionView reloadData];
        
	} else if (self.shouldReloadCollectionView) {
		// This is to prevent a bug in UICollectionView from occurring.
		// The bug presents itself when inserting the first object or deleting the last object in a collection view.
		// http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
		// This code should be removed once the bug has been fixed, it is tracked in OpenRadar
		// http://openradar.appspot.com/12954582
		self.collectionViewBlockOperation = nil;
		self.shouldReloadCollectionView = NO;
		[self.collectionView reloadData];
		
	} else if ([self.collectionViewBlockOperation.executionBlocks count] == 0) {
		self.collectionViewBlockOperation = nil;
		self.shouldReloadCollectionView = NO;
		
	} else {	//	BIG
        
		@try
		{
			[self.collectionView performBatchUpdates:^{
				[self.collectionViewBlockOperation start];
			} completion:^(BOOL finished) {
				self.collectionViewBlockOperation = nil;
			}];
		}
		@catch (NSException *except)
		{
			NSLog(@"DEBUG: failure to batch update.  %@", except.description);
			self.collectionViewBlockOperation = nil;
			self.shouldReloadCollectionView = NO;
			[self.collectionView reloadData];
		}
		
	}	//BIG else
}

- (void)clearChanges {
    
	self.collectionViewBlockOperation = nil;
	self.shouldReloadCollectionView = NO;
}
 */

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{

    if (response == ETSSynchronizationResponseAuthenticationError) {
        
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
    else if (response == ETSSynchronizationResponseValid) {
        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
            [self.navigationController popViewControllerAnimated:YES];
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
