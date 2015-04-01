//
//  ETSTableViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-09.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSSynchronization.h"
#import "ETSAuthenticationViewController.h"
#import "NSURLRequest+API.h"

@interface ETSTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, ETSSynchronizationDelegate, ETSAuthenticationViewControllerDelegate>

@property (strong, nonatomic) ETSSynchronization *synchronization;
@property (copy,   nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) BOOL dataNeedRefresh;
@property (assign, nonatomic) BOOL shouldRemoveFetchedDelegate;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end
