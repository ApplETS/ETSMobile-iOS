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
#import "ETSNewsEmptyCell.h"
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
    
    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    [ymdFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    for (NSDictionary *object in objects) {
        NSString *strippedContent = [object[@"entries"][@"content"] stringByStrippingHTML];
        if ([strippedContent length] > 0) {
            
            NSDate *date = [self.synchronization.dateFormatter dateFromString:object[@"entries"][@"updated"]];
            
            NSString *url = nil;
            
            NSScanner *scanner = [NSScanner scannerWithString:object[@"entries"][@"content"]];

            [scanner scanUpToString:@"<img" intoString:nil];
            if (![scanner isAtEnd]) {
                [scanner scanUpToString:@"src" intoString:nil];
                NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
                [scanner scanUpToCharactersFromSet:charset intoString:nil];
                [scanner scanCharactersFromSet:charset intoString:nil];
                [scanner scanUpToCharactersFromSet:charset intoString:&url];
            }
            
            if (url && [url rangeOfString:@"/safe_image.php"].location != NSNotFound) {
                NSRange range = [url rangeOfString:@"&amp;url="];
                url = [[url substringFromIndex:range.location + range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
            else if (!url) {
                url = @"";
            }
            
            if (![url hasSuffix:@".jpg"]) {
                url = @"";
            }

            NSAttributedString *contentStripped = [[NSAttributedString alloc] initWithData:[strippedContent dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
            NSAttributedString *author = [[NSAttributedString alloc] initWithData:[object[@"entries"][@"author"][@"name"] dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];

            [news addObject:@{@"id"                 : object[@"entries"][@"id"],
                              @"title"              : object[@"entries"][@"title"],
                              @"alternate"          : object[@"entries"][@"alternate"],
                              @"updated"            : object[@"entries"][@"updated"],
                              @"ymdDate"            : [ymdFormatter stringFromDate:date],
                              @"content"            : object[@"entries"][@"content"],
                              @"contentStripped"    : contentStripped.string,
                              @"author"             : author.string,
                              @"thumbnailURL"       : url}];
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
        ((ETSNewsCell *)cell).contentLabel.text = news.contentStripped;
        ((ETSNewsCell *)cell).authorLabel.text = news.author;
        ((ETSNewsCell *)cell).thumbnailView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:news.thumbnailURL]]];
        ((ETSNewsCell *)cell).thumbnailView.clipsToBounds = YES;
    } else if ([cell isKindOfClass:[ETSNewsEmptyCell class]]) {
        ((ETSNewsEmptyCell *)cell).contentLabel.text = news.contentStripped;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return 108.0f;
    else
        return 221.0f;
}

@end
