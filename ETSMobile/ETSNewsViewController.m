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

@implementation ETSNewsViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)updateDefaultNewsSource
{
    NSArray *sources = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NewsSources" ofType:@"plist"]];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"NewsSource";
    synchronization.compareKey = @"id";
    synchronization.ignoredAttributes = @[@"enabled"];
    synchronization.managedObjectContext = self.managedObjectContext;
    
    NSError *error = nil;
    [synchronization synchronizeJSONArray:sources error:&error];
    if (![self.managedObjectContext save:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (NSArray *)enabledSources
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"NewsSource"];
    request.predicate = [NSPredicate predicateWithFormat:@"enabled == 1"];
    return [self.managedObjectContext executeFetchRequest:request error:nil];
}

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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    
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
    
    [self updateDefaultNewsSource];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForNewsWithSources:[self enabledSources]];
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
    self.synchronization.request = [NSURLRequest requestForNewsWithSources:[self enabledSources]];
    [super viewWillAppear:animated];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSMutableArray *news = [NSMutableArray array];
    
    for (NSDictionary *object in objects) {
        NSString *strippedContent = [object[@"entries"][@"content"] stringByStrippingHTML];
        if ([strippedContent length] > 0) {
            [news addObject:@{@"id"                 : object[@"entries"][@"id"],
                              @"updated"            : object[@"entries"][@"updated"],
                              @"content"            : object[@"entries"][@"content"],
                              @"contentStripped"    : strippedContent,
                              @"author"             : object[@"entries"][@"author"][@"name"]}];
        }
    }
    return news;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldRemoveFetchedDelegate = NO;
    if ([segue.identifier isEqualToString:@"SourcesSegue"]) {
        ETSNewsSourceViewController *destinationController = (ETSNewsSourceViewController *)segue.destinationViewController;
        destinationController.managedObjectContext = self.managedObjectContext;
    }
    else if ([segue.identifier isEqualToString:@"NewsSegue"] || [segue.identifier isEqualToString:@"NewsImageSegue"]) {
        ETSNewsDetailsViewController *destinationController = (ETSNewsDetailsViewController *)segue.destinationViewController;
        destinationController.news = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    NSError *error = nil;
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[news.contentStripped dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    NSMutableAttributedString *res = [html mutableCopy];
    [res beginEditing];
    [res enumerateAttribute:NSFontAttributeName
                    inRange:NSMakeRange(0, res.length)
                    options:0
                 usingBlock:^(id value, NSRange range, BOOL *stop) {
                     if (value) {
                         UIFont *newFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
                         [res addAttribute:NSFontAttributeName value:newFont range:range];
                     }
                 }];
    [res endEditing];
    
    cell.textLabel.text = res.string;
}


@end
