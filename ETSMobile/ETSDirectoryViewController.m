//
//  ETSDirectoryViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSDirectoryViewController.h"
#import "NSURLRequest+API.h"
#import "ETSContact.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import <Crashlytics/Crashlytics.h>

@interface ETSDirectoryViewController ()
@property (nonatomic, copy) NSString *searchText;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIBarButtonItem *directoryBarButtonItem;
@end

@implementation ETSDirectoryViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    self.title = @"Bottin";
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    self.searchText = nil;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Directory"
                        contentType:@"Directory"
                          contentId:@"ETS-Directory"
                   customAttributes:@{}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //[self.directoryBarButtonItem.target performSelector:self.directoryBarButtonItem.action withObject:self.directoryBarButtonItem];
#pragma clang diagnostic pop
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.fetchedResultsController.delegate = nil;
    [self.synchronization saveManagedObjectContext];
    [super viewDidDisappear:animated];
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
    
    if (self.searchDisplayController.searchBar.text && [self.searchText length] > 0) {
        
        sectionNameKeyPath = nil;
        NSPredicate *predicate = nil;
        
        NSString *trimmedSearch = [self.searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSArray *names = [trimmedSearch componentsSeparatedByString:@" "];
        NSString *fullNameSearch = [[self.searchText componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@""];
        
        if ([names count] == 2) {
            predicate = [NSPredicate predicateWithFormat:@"((lastName contains[cd] %@) AND (firstName contains[cd] %@)) OR ((lastName contains[cd] %@) AND (firstName contains[cd] %@)) OR (fullName contains[cd] %@)", names[0], names[1], names[1], names[0], fullNameSearch];
        } else {
            
            predicate = [NSPredicate predicateWithFormat:@"(lastName contains[cd] %@) OR (firstName contains[cd] %@) OR (fullName contains[cd] %@)", trimmedSearch, trimmedSearch, fullNameSearch];
        }
        [fetchRequest setPredicate:predicate];
    }
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:sectionNameKeyPath cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
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
    if (tableView == self.searchDisplayController.searchResultsTableView) return nil;
    else {
        NSMutableArray* indexTitles = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
        [indexTitles addObjectsFromArray:[self.fetchedResultsController sectionIndexTitles]];
        return indexTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (title == UITableViewIndexSearch) {
        [self.tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
        return -1;
    }
    else
        return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index-1];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSContact *contact = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ABUnknownPersonViewController *personController = [[ABUnknownPersonViewController alloc] init];
    
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
  
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        ((UINavigationController *)self.splitViewController.viewControllers[1]).viewControllers = @[personController];
        [personController.navigationItem setLeftBarButtonItem:self.directoryBarButtonItem animated:YES];
    } else {
        [[self navigationController] pushViewController:personController animated:YES];
    }
    
    CFRelease(person);
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

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.directoryBarButtonItem = barButtonItem;
    barButtonItem.title = NSLocalizedString(@"Personnes", nil);
    [((UINavigationController *)self.splitViewController.viewControllers[1]).topViewController.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
