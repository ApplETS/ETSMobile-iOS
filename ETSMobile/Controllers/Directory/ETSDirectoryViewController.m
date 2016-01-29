//
//  ETSDirectoryViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSDirectoryViewController.h"
#import "ETSDirectoryResultsViewController.h"
#import "NSURLRequest+API.h"
#import "ETSContact.h"
#import "ETSDirectoryResultCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface ETSDirectoryViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) ETSDirectoryResultsViewController *resultsTableController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@end

@implementation ETSDirectoryViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _resultsTableController = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectoryResultsViewController"];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForDirectory];
    synchronization.entityName = @"Contact";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"d";
    synchronization.predicate = nil;
    synchronization.saveAutomatically = NO;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.cellIdentifier = @"ContactIdentifier";
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

- (void)viewDidDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    [self.synchronization saveManagedObjectContext];
    [super viewDidDisappear:animated];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 10;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastInitial" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSString *sectionNameKeyPath = @"lastInitial";
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!contact.firstName) {
        cell.textLabel.text = contact.lastName;
    }
    else {
        cell.textLabel.text = contact.fullName;
        NSMutableAttributedString * attributedName = [[NSMutableAttributedString alloc] initWithAttributedString:cell.textLabel.attributedText];
        NSRange boldedRange = NSMakeRange([contact.firstName length], [contact.lastName length]+1);
        
        UIFontDescriptor* fontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
        UIFontDescriptor* boldFontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        UIFont* boldFont =  [UIFont fontWithDescriptor:boldFontDescriptor size:0.0];
        
        [attributedName addAttribute: NSFontAttributeName value:boldFont range:boldedRange];
        
        [cell.textLabel setAttributedText:attributedName];
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray* indexTitles = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
    [indexTitles addObjectsFromArray:[self.fetchedResultsController sectionIndexTitles]];
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (index == 0) {
        [self.tableView scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
        return NSNotFound;
    }
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index-1];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView != tableView) {
        [self performSegueWithIdentifier:@"showContactSegue" sender:[self.resultsTableController.tableView cellForRowAtIndexPath:self.resultsTableController.tableView.indexPathForSelectedRow]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ETSContact *contact = [sender isKindOfClass:[ETSDirectoryResultCell class]] ? self.resultsTableController.filteredProducts[self.resultsTableController.tableView.indexPathForSelectedRow.row] : [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];

    UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
    ABUnknownPersonViewController *personController = [ABUnknownPersonViewController new];
    ABRecordRef person = ABPersonCreate();
    CFErrorRef  anError = NULL;
    
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge void*)contact.firstName, &anError);
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge void*)contact.lastName, &anError);
    ABRecordSetValue(person, kABPersonDepartmentProperty, (__bridge void*)contact.service, &anError);
    ABRecordSetValue(person, kABPersonJobTitleProperty, (__bridge void*)contact.job, &anError);
    
    if(contact.office) {
        ABRecordSetValue(person, kABPersonNoteProperty, (__bridge void*)contact.office, &anError);
    }
    
    if (contact.email) {
        ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiEmail,(__bridge void*)contact.email, (__bridge CFStringRef)@"email", nil);
        ABRecordSetValue(person, kABPersonEmailProperty, multiEmail, &anError);
        CFRelease(multiEmail);
    }
    
    if (contact.phone) {
        ABMutableMultiValueRef phone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phone, (__bridge void*)contact.phone, kABWorkLabel, nil);
        ABRecordSetValue(person, kABPersonPhoneProperty, phone, &anError);
        CFRelease(phone);
    }
    
    personController.allowsAddingToAddressBook = YES;
    personController.displayedPerson = person;
    [personController.view setTintColor:[UIColor blackColor]];
    
    // Prevent personController to appear under the navbar.
    personController.edgesForExtendedLayout = UIRectEdgeNone;
    
    CFRelease(person);
    navController.viewControllers = @[personController];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSContact *contact = (ETSContact *)managedObject;
    
    contact.firstInitial = [[[NSString alloc] initWithData:[[contact.firstName substringToIndex:1] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding] uppercaseString];
    contact.lastInitial = [[[NSString alloc] initWithData:[[contact.lastName substringToIndex:1] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES] encoding:NSASCIIStringEncoding] uppercaseString];
    contact.fullName = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    self.dataNeedRefresh = NO;
    if ([[self.fetchedResultsController sections] count] == 0) {
        [self.synchronization saveManagedObjectContext];
    }
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return ([secondaryViewController isKindOfClass:[UINavigationController class]]
            && ![[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[ABUnknownPersonViewController class]]);
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
        
        NSExpression *lhs = [NSExpression expressionForKeyPath:@"firstName"];
        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
        NSPredicate *finalPredicate = [NSComparisonPredicate
                                       predicateWithLeftExpression:lhs
                                       rightExpression:rhs
                                       modifier:NSDirectPredicateModifier
                                       type:NSContainsPredicateOperatorType
                                       options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"lastName"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"email"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"job"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"office"];
        rhs = [NSExpression expressionForConstantValue:searchString];
        finalPredicate = [NSComparisonPredicate
                          predicateWithLeftExpression:lhs
                          rightExpression:rhs
                          modifier:NSDirectPredicateModifier
                          type:NSContainsPredicateOperatorType
                          options:NSCaseInsensitivePredicateOption];
        [searchItemsPredicate addObject:finalPredicate];
        
        lhs = [NSExpression expressionForKeyPath:@"service"];
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
    
    ETSDirectoryResultsViewController *tableController = (ETSDirectoryResultsViewController *)self.searchController.searchResultsController;
    tableController.filteredProducts = searchResults;
    [tableController.tableView reloadData];
}

#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}


@end
