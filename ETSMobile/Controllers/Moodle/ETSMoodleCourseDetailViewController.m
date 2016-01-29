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
#import "ETSMoodleCourseResultsViewController.h"
#import "ETSMoodleResultViewCell.h"
#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ETSMoodleCourseDetailViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ETSMoodleCourseResultsViewController *resultsTableController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
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
    
    _resultsTableController = [self.storyboard instantiateViewControllerWithIdentifier:@"MoodleCourseResultsViewController"];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    
    self.acceptedTypes = @[@"url", @"resource", @"forum", @"choicegroup", @"wiki", @"assign", @"page"];
    
    self.cellIdentifier = @"MoodleIdentifier";
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    if (self.token && [self.token length] > 0) {
        [self initializeSynchronization];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSMoodleElement *element = (ETSMoodleElement *)managedObject;
    if ([element managedObjectContext]) {
        element.course = (ETSMoodleCourse *)[element.managedObjectContext objectWithID:[self.course objectID]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return element.header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
   
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
    ETSMoodleElement *element = tableView != self.tableView ? self.resultsTableController.filteredProducts[self.resultsTableController.tableView.indexPathForSelectedRow.row] : [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    
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
    ETSMoodleElement *element = [sender isKindOfClass:[ETSMoodleResultViewCell class]] ? self.resultsTableController.filteredProducts[self.resultsTableController.tableView.indexPathForSelectedRow.row] : [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    
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
    ETSMoodleElement *element = [sender isKindOfClass:[ETSMoodleResultViewCell class]] ? self.resultsTableController.filteredProducts[self.resultsTableController.tableView.indexPathForSelectedRow.row] : [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    
    return [identifier isEqualToString:@"pageSegue"] && [element.type isEqualToString:@"page"];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    }
    
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        
        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"filename"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
        [andMatchPredicates addObject:orMatchPredicates];
    }
    
    NSCompoundPredicate *finalCompoundPredicate =
    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    
    ETSMoodleCourseResultsViewController *tableController = (ETSMoodleCourseResultsViewController *)self.searchController.searchResultsController;
    tableController.filteredProducts = searchResults;
    [tableController.tableView reloadData];
}

#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey2 = @"ViewControllerTitleKey2";
NSString *const SearchControllerIsActiveKey2 = @"SearchControllerIsActiveKey2";
NSString *const SearchBarTextKey2 = @"SearchBarTextKey2";
NSString *const SearchBarIsFirstResponderKey2 = @"SearchBarIsFirstResponderKey2";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey2];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey2];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey2];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey2];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey2];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey2];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey2];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey2];
}

@end
