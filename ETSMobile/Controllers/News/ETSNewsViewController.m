//
//  ETSNewsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-19.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsViewController.h"
#import "ETSNewsSourceViewController.h"
#import "ETSNewsCell.h"
#import "ETSNewsEmptyCell.h"
#import "NSURL+Document.h"
#import "ETSNews.h"
#import "NSString+HTML.h"
#import "GTMNSString+HTML.h"
#import "UIImageView+WebCache.h"
#import "STKWebKitViewController.h"
#import "TUSafariActivity.h"
#import "UIColor+Styles.h"

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
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"ymdDate" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"updatedDate" ascending:NO]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"ymdDate" cacheName:nil];
    
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
    
    self.tableView.estimatedRowHeight = 133.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self updateDefaultNewsSource];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForNewsWithSources:[self enabledSources]];
    synchronization.entityName = @"News";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"data";
    synchronization.dateFormatter = dateFormatter;
    synchronization.appletsServer = YES;
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
    
    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    [ymdFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
    
    NSArray *keys = [((NSDictionary *)objects) allKeys];
    
    for (NSString *key in keys) {
        
        for (NSDictionary *object in objects[key]) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithDictionary:object];
            NSDate *date = [self.synchronization.dateFormatter dateFromString:object[@"updated_time"]];
            
            NSString *dateString = [ymdFormatter stringFromDate:date];

            if (dateString) {
                entry[@"ymdDate"] = dateString;
                [news addObject:entry];
            }
        }
        
    }
    return news;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Partager" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                  {
                                      NSArray *activityItems = @[news.title, [NSURL URLWithString:news.link]];
                                      UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
                                      activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                      
                                      [self presentViewController:activityViewController animated:YES completion:nil];
                                  }];
    // #BDBEC2
    share.backgroundColor = [UIColor colorWithRed:189.0f/255.0f green:190.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    
    
    UITableViewRowAction *open = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Ouvrir\ndans Safari" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:news.link]];
                                     }];
    // #34AADC
    open.backgroundColor = [UIColor colorWithRed:52.0f/255.0f green:170.0f/255.0f blue:220.0f/255.0f alpha:1.0f];
    
    return @[open, share];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.shouldRemoveFetchedDelegate = NO;
    if ([segue.identifier isEqualToString:@"SourcesSegue"]) {
        UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
        ETSNewsSourceViewController * destinationController = (ETSNewsSourceViewController *)destinationNavController.visibleViewController;
        destinationController.managedObjectContext = self.managedObjectContext;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath != nil) {
        // Getting news for index path
        ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSURL *url = [NSURL URLWithString:news.link];
        STKWebKitViewController *webViewController = [[STKWebKitViewController alloc] initWithURL:url];
        
        // Customization
        webViewController.toolbarItemTintColor = [UIColor naviguationBarTintColor];
        
        // FIXME Open in safari Activity
        // TUSafariActivity *activity = [[TUSafariActivity alloc] init];
        // webViewController.applicationActivities = @[activity];
        
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];

    UITableViewCell *cell = nil;
    if (news.thumbnailURL && news.thumbnailURL.length > 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NewsEmptyIdentifier" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[ETSNewsCell class]]) {
        ((ETSNewsCell *)cell).contentTextView.text = news.content;
        ((ETSNewsCell *)cell).contentTextView.textColor = [UIColor blackColor];
        ((ETSNewsCell *)cell).contentTextView.textContainer.exclusionPaths = @[[UIBezierPath bezierPathWithRect:((ETSNewsCell *)cell).thumbnailView.bounds]];
        ((ETSNewsCell *)cell).authorLabel.text = news.author;
        ((ETSNewsCell *)cell).thumbnailView.image = nil;
        [((ETSNewsCell *)cell).thumbnailView sd_setImageWithURL:[NSURL URLWithString:news.thumbnailURL]];
                ((ETSNewsCell *)cell).thumbnailView.clipsToBounds = YES;
    } else if ([cell isKindOfClass:[ETSNewsEmptyCell class]]) {
        ((ETSNewsEmptyCell *)cell).contentTextView.text = news.content;
        ((ETSNewsCell *)cell).contentTextView.textColor = [UIColor blackColor];
        ((ETSNewsEmptyCell *)cell).authorLabel.text = news.author;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    ymdFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [ymdFormatter dateFromString:sectionInfo.name];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"EEEE, d MMMM YYYY";

    return [dateFormatter stringFromDate:date];
}

@end
