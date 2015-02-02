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
#import "GTMNSString+HTML.h"

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
    
    #ifdef __USE_TESTFLIGHT
    [TestFlight passCheckpoint:@"NEWS_VIEWCONTROLLER"];
    #endif
    
    [self updateDefaultNewsSource];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
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
    [ymdFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSArray *keys = [((NSDictionary *)objects) allKeys];
    
    for (NSString *key in keys) {
        
      //  [news addObjectsFromArray:objects[key]];
        
        for (NSDictionary *object in objects[key]) {
            NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithDictionary:object];
            NSDate *date = [self.synchronization.dateFormatter dateFromString:object[@"updated_time"]];
            entry[@"ymdDate"] = [ymdFormatter stringFromDate:date];
            [news addObject:entry];
            NSLog(@"%@", entry[@"message"]);
        }
        
        
        
        /*
        NSString *strippedContent = [object[@"entries"][@"content"] stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        strippedContent = [strippedContent stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        strippedContent = [strippedContent stringByStrippingHTML];

        if ([[object[@"entries"][@"content"] stringByStrippingHTML] length] > 0) {
            
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
            
            NSString *unescapedContent = [strippedContent gtm_stringByUnescapingFromHTML];
            NSString *unescapedAuthor = [object[@"entries"][@"author"][@"name"] gtm_stringByUnescapingFromHTML];
            
            BOOL isComplete = object[@"entries"][@"id"] && object[@"entries"][@"title"] && object[@"entries"][@"alternate"] && object[@"entries"][@"updated"] && [ymdFormatter stringFromDate:date] && object[@"entries"][@"content"] && unescapedContent && unescapedAuthor && url;
            
            if (isComplete) {
                [news addObject:@{@"id"                 : object[@"entries"][@"id"],
                                  @"title"              : object[@"entries"][@"title"],
                                  @"alternate"          : object[@"entries"][@"alternate"],
                                  @"updated"            : object[@"entries"][@"updated"],
                                  @"ymdDate"            : [ymdFormatter stringFromDate:date],
                                  @"content"            : object[@"entries"][@"content"],
                                  @"contentStripped"    : unescapedContent,
                                  @"author"             : unescapedAuthor,
                                  @"thumbnailURL"       : url}];
            }
        }
         */
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
        destinationController.title = destinationController.news.author;
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
        ((ETSNewsCell *)cell).contentLabel.text = news.title;
        ((ETSNewsCell *)cell).authorLabel.text = news.author;
        ((ETSNewsCell *)cell).thumbnailView.image = nil;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:news.thumbnailURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                          {
                              if (data) {
                                  UIImage *image = [UIImage imageWithData:data];
                                  if (image && image.size.height > 0 && image.size.width > 0) {
                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                          ((ETSNewsCell *)cell).thumbnailView.image = [UIImage imageWithData:data];
                                      });
                                  }
                              }
                          }];
        [task resume];
        
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
