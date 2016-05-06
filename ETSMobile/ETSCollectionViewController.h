//
//  ETSCollectionViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSSynchronization.h"
#import "ETSAuthenticationViewController.h"

@interface ETSCollectionViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate, ETSSynchronizationDelegate, ETSAuthenticationViewControllerDelegate>

@property (strong, nonatomic) ETSSynchronization *synchronization;
@property (copy,   nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
