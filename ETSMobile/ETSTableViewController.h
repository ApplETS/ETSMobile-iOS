//
//  ETSTableViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-09.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSConnection.h"
#import "ETSAuthenticationViewController.h"

@interface ETSTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, ETSConnectionDelegate, ETSAuthenticationViewControllerDelegate>

@property (strong, nonatomic) ETSConnection *connection;
@property (copy,   nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) BOOL dataNeedRefresh;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
