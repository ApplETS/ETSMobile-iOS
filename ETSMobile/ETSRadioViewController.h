//
//  ETSRadioViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"

@interface ETSRadioViewController : UICollectionViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
