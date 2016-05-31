//
//  ETSMoodleCourseDetailViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSMoodleCourseDetailViewController.h"
#import "ETSMoodleElement.h"
#import "ETSWebViewViewController.h"
#import "ETSAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import <Crashlytics/Crashlytics.h>

@interface ETSMoodleCourseDetailViewController ()
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSArray *acceptedTypes;
@end

@implementation ETSMoodleCourseDetailViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    [self.synchronization synchronize:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.acceptedTypes = @[@"url", @"resource", @"forum", @"choicegroup", @"wiki", @"assign", @"page"];
    
    self.cellIdentifier = @"MoodleIdentifier";
    
    self.searchText = nil;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    if (self.token && [self.token length] > 0) {
        [self initializeSynchronization];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Moodle courses detail"
                        contentType:@"Moodle"
                          contentId:@"ETS-Moodle-Detail"
                   customAttributes:@{}];
}

- (void)initializeSynchronization
{
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForMoodleCourseDetailWithToken:self.token courseid:[self.course.id stringValue]];
    synchronization.entityName = @"MoodleElement";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"";
    synchronization.predicate = [NSPredicate predicateWithFormat:@"course.id == %@", self.course.id];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.synchronization synchronize:nil];
}

- (void)refreshView
{
    [self initializeSynchronization];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodleElement" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"parentid" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSMutableArray *predicates = [NSMutableArray arrayWithArray:@[[NSPredicate predicateWithFormat:@"visible == YES"], [NSPredicate predicateWithFormat:@"course.id == %@", self.course.id]]];
    
    if (self.searchDisplayController.searchBar.text && [self.searchText length] > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", self.searchText]];
    }
    
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"parentid" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if ([objects isKindOfClass:[NSDictionary class]]) return @[];
    
    NSMutableArray *elements = [NSMutableArray array];
    
    for (NSDictionary *module in objects) {
        if (!module[@"modules"]) continue;
        
        for (NSDictionary *element in module[@"modules"]) {
            if ([element[@"modname"] isEqualToString:@"label"]) continue;
            
            NSMutableDictionary *parsedElement = [NSMutableDictionary dictionary];
            if (module[@"id"])          parsedElement[@"parentid"]  = module[@"id"];
            if (module[@"name"])        parsedElement[@"header"]    = module[@"name"];
            if (element[@"id"])         parsedElement[@"id"]        = element[@"id"];
            if (element[@"modname"])    parsedElement[@"type"]      = element[@"modname"];
            if (element[@"name"])       parsedElement[@"name"]      = element[@"name"];
            if (element[@"visible"])    parsedElement[@"visible"]   = element[@"visible"];
            if (element[@"contents"][0]) {
                if (element[@"contents"][0][@"filename"])  parsedElement[@"filename"]  = element[@"contents"][0][@"filename"];
                if (element[@"contents"][0][@"fileurl"])   parsedElement[@"url"]       = element[@"contents"][0][@"fileurl"];
            } else {
                if (element[@"url"]) parsedElement[@"url"] = element[@"url"];
            }
            [elements addObject:parsedElement];
        }
    }
    
    return elements;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.searchText = searchText;
    self.fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchText = nil;
    self.fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSMoodleElement *element = (ETSMoodleElement *)managedObject;
    element.course = (ETSMoodleCourse *)[element.managedObjectContext objectWithID:[self.course objectID]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return element.header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = element.name;
    if ([element.type isEqualToString:@"resource"] && !self.token) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (![self.acceptedTypes containsObject:element.type]) return;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        ETSWebViewViewController *controller = (ETSWebViewViewController *)((UINavigationController *)self.splitViewController.viewControllers[1]).topViewController;
        controller.title = element.name;

        if ([element.type isEqualToString:@"resource"]) {
            [controller setRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&token=%@", element.url, self.token]]]];
        } else if ([element.type isEqualToString:@"page"]) {
            NSString *URL = [NSString stringWithFormat:@"%@&token=%@", element.url, self.token];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              dispatch_sync(dispatch_get_main_queue(), ^{
                                                  
                                                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                  CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)response.URL.lastPathComponent.pathExtension, NULL);
                                                  CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
                                                  
                                                  NSString *encoding = response.textEncodingName;
                                                  if (!encoding) encoding = @"utf-8";
                                                  [controller loadData:data MIMEType:(__bridge NSString *)MIMEType textEncodingName:encoding baseURL:request.URL.baseURL];
                                                  
                                                  CFRelease(MIMEType);
                                                  CFRelease(UTI);
                                              });
                                              
                                          }];
            [task resume];
        }
        else {
            [controller setRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:element.url]]];
        }
    } else {
        if ([element.type isEqualToString:@"resource"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&token=%@", element.url, self.token]]];
        } else if ([element.type isEqualToString:@"page"]) {
            return;
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:element.url]];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    if (![element.type isEqualToString:@"page"]) return;
        
    ETSWebViewViewController *controller = (ETSWebViewViewController *)segue.destinationViewController;
    controller.title = element.name;
    NSString *URL = [NSString stringWithFormat:@"%@&token=%@", element.url, self.token];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      dispatch_sync(dispatch_get_main_queue(), ^{
                                          
                                          [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                          if (error) return;
                                          
                                          CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)response.URL.lastPathComponent.pathExtension, NULL);
                                          CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
                                          
                                          NSString *encoding = response.textEncodingName;
                                          if (!encoding) encoding = @"utf-8";

                                          [controller loadData:data MIMEType:(__bridge NSString *)MIMEType textEncodingName:encoding baseURL:request.URL.baseURL];
                                          
                                          CFRelease(MIMEType);
                                          CFRelease(UTI);
                                      });
                                  }];
    [task resume];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    
    return [identifier isEqualToString:@"pageSegue"] && [element.type isEqualToString:@"page"];
}

@end
