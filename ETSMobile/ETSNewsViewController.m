//
//  ETSNewsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-07-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSNewsViewController.h"
#import "ETSNewsSourceViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "ETSNewsDetailsViewController.h"
#import "ETSNewsCell.h"
#import "NSURL+Document.h"
#import "NSString+HTML.h"
#import "ETSNews.h"

@interface ETSNewsViewController ()
@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, copy) NSString *path;
@end

@implementation ETSNewsViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"News" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    
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
    
    self.path = [[[NSURL applicationDocumentsDirectory] URLByAppendingPathComponent:@"NewsSources.plist"] path];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:self.path]) {
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"NewsSources" ofType:@"plist"] toPath:self.path error:nil];
    }
    
    self.sources = [NSMutableArray arrayWithContentsOfFile:self.path];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    self.cellIdentifier = @"NewsIdentifier";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForNewsWithSources:self.sources];
    synchronization.entityName = @"News";
    synchronization.compareKey = @"link";
    synchronization.objectsKeyPath = @"query.results.feed";
    synchronization.dateFormatter = dateFormatter;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.synchronization.request = [NSURLRequest requestForNewsWithSources:self.sources];
    [super viewWillAppear:animated];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSMutableArray *news = [NSMutableArray array];
    for (NSDictionary *entry in objects) {
        NSDictionary *item = entry[@"entry"];
        if (![item[@"title"] isKindOfClass:[NSNull class]] && [item[@"title"] length] > 0) {
            NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:item];
            new[@"link"] = item[@"link"][@"href"];
            if (!item[@"summary"] && item[@"content"]) {
                new[@"summary"] = item[@"content"];
            }
            [news addObject:new];
        }
    }
    return news;
}

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SourcesSegue"]) {
        ETSNewsSourceViewController *destinationController = (ETSNewsSourceViewController *)segue.destinationViewController;
        destinationController.sources = self.sources;
        destinationController.savePath = self.path;
    }
    else if ([segue.identifier isEqualToString:@"NewsSegue"]) {
        ETSNewsDetailsViewController *destinationController = (ETSNewsDetailsViewController *)segue.destinationViewController;
        destinationController.news = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

- (IBAction)panLeftMenu:(id)sender
{
    [((MFSideMenuContainerViewController *)self.navigationController.parentViewController) toggleLeftSideMenuCompletion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126;
}

- (void)configureCell:(ETSNewsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSError *error = nil;
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[news.content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithData:[news.title dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    cell.titleLabel.text = [title string];
    
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
    
    cell.summaryLabel.attributedText = res;
    
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSNews *news = (ETSNews *)managedObject;
    for (NSDictionary *source in self.sources) {
        if ([news.link rangeOfString:source[@"id"]].location != NSNotFound) {
            news.source = source[@"id"];
            break;
        }
    }
    
    if ([news.source isEqualToString:@"etsmtl.ca"]) {
        NSMutableArray *lines = [NSMutableArray arrayWithArray:[[news.summary stringByStrippingHTML] componentsSeparatedByString:@"\n"]];
        [lines removeObjectsInRange:NSMakeRange(0, 2)];
        
        news.content = [lines componentsJoinedByString:@"\n"];
    }
    
    else {
        news.content = [news.summary stringByStrippingHTML];
    }
}


@end
