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
#import "ETSNewsImageCell.h"
#import "NSURL+Document.h"
#import "NSString+HTML.h"
#import "ETSNews.h"

@interface ETSNewsViewController ()
@property (nonatomic, strong) NSMutableArray *sources;
@property (nonatomic, copy) NSString *path;
@end

@implementation ETSNewsViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (NSPredicate *)predicateForSelectedNews
{
    NSMutableArray *predicates = [NSMutableArray array];
    for (NSDictionary *source in self.sources) {
        if ([source[@"enabled"] boolValue]) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"source ==[c] %@", source[@"id"]]];
        }
    }
    
    return [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"News"];
    
    fetchRequest.fetchBatchSize = 8;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:NO]];
    fetchRequest.predicate = [self predicateForSelectedNews];
    
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
    synchronization.ignoredAttributes = @[@"image"];
    synchronization.predicate = [self predicateForSelectedNews];
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!self.shouldRemoveFetchedDelegate) {
        // Inspiré de http://stackoverflow.com/questions/13299120/nsfetchedresultscontrollers-delegate-doesnt-fire-after-predicate-is-changed
        // Le delegate du NSFetchedResultsController n'appelle pas les animations lorsque l'on
        // change le predicate et que l'on effectue un performFetch.
        NSArray* objectsBefore = self.fetchedResultsController.fetchedObjects;
        
        self.fetchedResultsController.fetchRequest.predicate = [self predicateForSelectedNews];
        [self.fetchedResultsController performFetch:nil];
        
        NSArray* objectsAfter = self.fetchedResultsController.fetchedObjects;
        
        [self.tableView beginUpdates];
        
        if (objectsBefore.count > 0) {
            for (id objectBefore in objectsBefore) {
                if ([objectsAfter indexOfObject:objectBefore] == NSNotFound) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[objectsBefore indexOfObject:objectBefore] inSection:0];
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                }
            }
        }
        
        if (objectsAfter.count > 0) {
            for (id objectAfter in objectsAfter) {
                if ([objectsBefore indexOfObject:objectAfter] == NSNotFound) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[objectsAfter indexOfObject:objectAfter] inSection:0];
                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
                }
            }
        }
        
        [self.tableView endUpdates];
        self.shouldRemoveFetchedDelegate = YES;
    }
    
    self.synchronization.predicate = [self predicateForSelectedNews];
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

- (IBAction)panLeftMenu:(id)sender
{
    [((MFSideMenuContainerViewController *)self.navigationController.parentViewController) toggleLeftSideMenuCompletion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 126;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[news.image length] == 0 ? @"NewsIdentifier" : @"NewsImageIdentifier" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSNews *news = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSError *error = nil;
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[news.content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithData:[news.title dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
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
    
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    dateFormatter.locale = locale;
    dateFormatter.dateFormat = @"EEEE, MMMM d";
    
    if ([cell isKindOfClass:[ETSNewsImageCell class]]) {
        ((ETSNewsImageCell *)cell).titleLabel.text = [title string];
        ((ETSNewsImageCell *)cell).summaryLabel.attributedText = res;
        UIImage *image = [UIImage imageWithData:news.image];
        ((ETSNewsImageCell *)cell).newsImageView.image = image;
    } else if ([cell isKindOfClass:[ETSNewsCell class]]) {
        ((ETSNewsCell *)cell).titleLabel.text = [title string];
        ((ETSNewsCell *)cell).summaryLabel.attributedText = res;
        ((ETSNewsCell *)cell).dateLabel.text = [dateFormatter stringFromDate:news.published];
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
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

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    [super synchronizationDidFinishLoading:synchronization];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    context.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"News"];
    request.predicate = [NSPredicate predicateWithFormat:@"image == nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"published" ascending:YES]];
    NSArray *newsToFetch = [context executeFetchRequest:request error:nil];
    
    NSBlockOperation *operations = [NSBlockOperation new];
    __weak typeof(self) bself = self;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    for (ETSNews *news in newsToFetch) {
        if ([news.image length] == 0) {
            [operations addExecutionBlock:^{
                NSString *url = nil;
                NSScanner *scanner = [NSScanner scannerWithString:news.summary];
                
                [scanner scanUpToString:@"<img" intoString:nil];
                if (![scanner isAtEnd]) {
                    [scanner scanUpToString:@"src" intoString:nil];
                    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"\"'"];
                    [scanner scanUpToCharactersFromSet:charset intoString:nil];
                    [scanner scanCharactersFromSet:charset intoString:nil];
                    [scanner scanUpToCharactersFromSet:charset intoString:&url];
                    
                    if (url && [url length] > 0 && [url rangeOfString:@"f-partage.aspx" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                        if (data && [data length] > 0) {
                            UIImage *image = [UIImage imageWithData:data];
                            if (image.size.width > 20 && image.size.height > 20) {
                                news.image = data;
                            }
                        }
                    }
                }
            }];
        }
    }

    [operations setCompletionBlock:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [context save:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:bself name:NSManagedObjectContextDidSaveNotification object:context];
        
        NSMutableArray *indexes = [NSMutableArray array];
        for (ETSNews *news in newsToFetch) {
            if (news.image && [news.image length] > 0) {
                [indexes addObject:[bself.fetchedResultsController indexPathForObject:news]];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [bself.tableView reloadRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        
    }];
    [operations start];
}

- (void)addControllerContextDidSave:(NSNotification*)saveNotification
{
    [self.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:saveNotification waitUntilDone:YES];
}



@end
