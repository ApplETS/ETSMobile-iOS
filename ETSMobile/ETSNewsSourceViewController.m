//
//  ETSNewsSourceViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsSourceViewController.h"
#import "ETSNewsSource.h"

#import <Crashlytics/Crashlytics.h>

@interface ETSNewsSourceViewController()
@property (nonatomic, strong) NSArray *sources;
@end

@implementation ETSNewsSourceViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NewsSource"];
    
    fetchRequest.fetchBatchSize = 30;
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

- (NSInteger)numberOfEnabledSources
{
    return [[self.sources valueForKeyPath:@"@sum.enabled"] integerValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"SourceIdentifier";
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"NewsSource"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"group" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.sources = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"News Sources"
                        contentType:@"News"
                          contentId:@"ETS-News-Sources"
                   customAttributes:@{}];
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
        case 1: return @"Services";
        case 2: return @"Science et technologie";
        case 3: return @"Engagement social et coopératif";
        case 4: return @"Art et culture";
        case 5: return @"Sports";
        default: return @"";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNewsSource *source = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    BOOL wantToDisable = [source.enabled boolValue];
    
    if (!wantToDisable || [self numberOfEnabledSources] > 1) {
        source.enabled = [NSNumber numberWithBool:![source.enabled boolValue]];
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
