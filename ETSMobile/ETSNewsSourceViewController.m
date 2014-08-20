//
//  ETSNewsSourceViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsSourceViewController.h"
#import "ETSNewsSource.h"

@implementation ETSNewsSourceViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsSource"];
    
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"group" cacheName:nil];
    
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"NEWSSOURCE_VIEWCONTROLLER"];
    
    self.cellIdentifier = @"SourceIdentifier";
    
    self.preferredContentSize = CGSizeMake(400, 250);
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNewsSource *source = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = source.name;
    cell.accessoryType = ([source.enabled boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"";
        case 1: return @"Science et technologie";
        case 2: return @"Engagement social et coopératif";
        case 3: return @"Art et culture";
        case 4: return @"Sports";
        default: return @"";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNewsSource *source = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    source.enabled = [NSNumber numberWithBool:![source.enabled boolValue]];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
