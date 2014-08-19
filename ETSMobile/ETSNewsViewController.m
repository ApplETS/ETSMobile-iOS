//
//  ETSNewsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-19.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsViewController.h"
#import "ETSNewsSourceViewController.h"
#import "ETSNewsDetailsViewController.h"
#import "ETSNewsCell.h"
#import "NSURL+Document.h"
#import "ETSNews.h"
#import "NSString+HTML.h"

@interface ETSNewsViewController ()
@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, copy) NSString *path;
@end

@implementation ETSNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"News"];
    
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updated" ascending:NO]];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"NEWS_VIEWCONTROLLER"];
    
    self.path = [[[NSURL applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsSources.plist"] path];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"NewsSources" ofType:@"plist"] toPath:self.path error:nil];
    }
    
    self.sources = [NSMutableArray arrayWithContentsOfFile:self.path];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForNewsWithSources:self.sources];
    synchronization.entityName = @"News";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"query.results.json";
    synchronization.dateFormatter = dateFormatter;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor lightGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.synchronization.request = [NSURLRequest requestForNewsWithSources:self.sources];
    [super viewWillAppear:animated];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSMutableArray *news = [NSMutableArray array];
    
    for (NSDictionary *object in objects) {
        [news addObject:@{@"id"                 : object[@"entries"][@"id"],
                          @"updated"            : object[@"entries"][@"updated"],
                          @"content"            : object[@"entries"][@"content"],
                          @"contentStripped"    : [object[@"entries"][@"content"] stringByStrippingHTML],
                          @"author"             : object[@"entries"][@"author"][@"name"]}];
    }
    return news;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldRemoveFetchedDelegate = NO;
    if ([segue.identifier isEqualToString:@"SourcesSegue"]) {
        ETSNewsSourceViewController *destinationController = (ETSNewsSourceViewController *)segue.destinationViewController;
        destinationController.sources = self.sources;
        destinationController.savePath = self.path;
    }
    else if ([segue.identifier isEqualToString:@"NewsSegue"] || [segue.identifier isEqualToString:@"NewsImageSegue"]) {
        ETSNewsDetailsViewController *destinationController = (ETSNewsDetailsViewController *)segue.destinationViewController;
        destinationController.news = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = news.contentStripped;
}


@end
