//
//  ETSCalendarViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-24.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ETSCalendarViewController : UICollectionViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
