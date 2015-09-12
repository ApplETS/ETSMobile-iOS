//
//  ETSBandwidthViewController.h
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSSynchronization.h"
#import "NSURLRequest+API.h"

@interface ETSBandwidthViewController: UIViewController <NSFetchedResultsControllerDelegate, ETSSynchronizationDelegate>
    @property (strong, nonatomic) ETSSynchronization *synchronization;
    @property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
    @property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
    @property (assign, nonatomic) BOOL dataNeedRefresh;
    @property (assign, nonatomic) BOOL shouldRemoveFetchedDelegate;
@end
