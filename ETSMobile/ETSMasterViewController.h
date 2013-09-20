//
//  ETSMasterViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETSDetailViewController;

#import <CoreData/CoreData.h>

@interface ETSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ETSDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
