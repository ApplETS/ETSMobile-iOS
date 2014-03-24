//
//  ETSRadioViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSRadioViewController.h"
#import "ETSAppDelegate.h"
#import "MFSideMenu.h"
#import "ETSEvent.h"
#import <AVFoundation/AVFoundation.h>

@interface ETSRadioViewController ()
- (AVPlayer *)radioPlayer;
@property (nonatomic, strong) UIBarButtonItem *playBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *pauseBarButtonItem;
@end

@implementation ETSRadioViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (AVPlayer *)radioPlayer
{
    return [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] radioPlayer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];

    
    self.playBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playRadio:)];
    self.pauseBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseRadio:)];

    if ([self radioPlayer] && [[self radioPlayer] rate])
        self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
    else
        self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
    
    self.title = @"Radio Piranha";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForRadio];
    synchronization.entityName = @"Event";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"programmation_radiopiranha";
    synchronization.predicate = nil;
    synchronization.dateFormatter = dateFormatter;
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.cellIdentifier = @"RadioCell";
    
    // CALENDRIER : VOIR SUNRISE
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 10;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([[self.navigationController viewControllers] count] > 1)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController | MFSideMenuPanModeSideMenu;
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.title;

}

- (IBAction)playRadio:(id)sender
{
    [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] startRadio];
    
    self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
}

- (IBAction)pauseRadio:(id)sender
{
    [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] stopRadio];
    
    self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
}

@end
