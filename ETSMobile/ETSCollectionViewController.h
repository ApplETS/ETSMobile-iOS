//
//  ETSCollectionViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSConnection.h"
#import "ETSAuthenticationViewController.h"

@interface ETSCollectionViewController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, ETSConnectionDelegate, ETSAuthenticationViewControllerDelegate>

@property (nonatomic, copy)   NSString *entityName;
@property (nonatomic, copy)   NSString *objectsKeyPath;
@property (nonatomic, copy)   NSString *compareKey;
@property (nonatomic, strong) NSURLRequest *request;

@property (strong, nonatomic) ETSConnection *connection;
@property (copy,   nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
