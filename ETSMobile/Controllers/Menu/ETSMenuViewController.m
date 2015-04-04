//
//  ETSMenuViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-07-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSMenuViewController.h"
#import "ETSWebViewViewController.h"
#import "UIColor+Styles.h"
#import "AppDelegate.h"
#import "ETSTableViewController.h"
#import "ETSMenuCell.h"
#import "ETSMenuTableViewHeader.h"

NSString * const kStoryboardAuthenticationViewController = @"AuthenticationViewController";
NSString * const ETSMenuCellReuseIdentifier = @"MenuCell";
NSString * const ETSDrawerHeaderReuseIdentifier = @"HeaderCell";

@interface ETSMenuViewController ()
@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllerIcons;
@property (nonatomic, strong) NSDictionary *paneViewControllerIdentifiers;
@property (nonatomic, strong) UIBarButtonItem *paneRevealLeftBarButtonItem;
@end

@implementation ETSMenuViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor menuSeparatorColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithRed:33/255.0f green:33/255.0f blue:33/255.0f alpha:1];
    [self.tableView registerClass:[ETSMenuCell class] forCellReuseIdentifier:ETSMenuCellReuseIdentifier];
    [self.tableView registerClass:[ETSMenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:ETSDrawerHeaderReuseIdentifier];
}

- (void)initialize
{
    self.paneViewControllerTitles = @{
                                           @(ETSPaneViewControllerTypeAbout)        : NSLocalizedString(@"À propos d’ÉTSMobile", nil),
                                           @(ETSPaneViewControllerTypeBandwidth)    : NSLocalizedString(@"Bande passante", nil),
                                           @(ETSPaneViewControllerTypeCalendar)     : NSLocalizedString(@"Horaire", nil),
                                           @(ETSPaneViewControllerTypeComment)      : NSLocalizedString(@"Problème ou commentaire?", nil),
                                           @(ETSPaneViewControllerTypeCourses)      : NSLocalizedString(@"Notes", nil),
                                           @(ETSPaneViewControllerTypeDirectory)    : NSLocalizedString(@"Bottin", nil),
                                           @(ETSPaneViewControllerTypeLibrary)      : NSLocalizedString(@"Bibliothèque", nil),
                                           @(ETSPaneViewControllerTypeMoodle)       : NSLocalizedString(@"Moodle", nil),
                                           @(ETSPaneViewControllerTypeNews)         : NSLocalizedString(@"Actualités", nil),
                                           @(ETSPaneViewControllerTypeProfile)      : NSLocalizedString(@"Profil", nil),
                                           @(ETSPaneViewControllerTypeRadio)        : NSLocalizedString(@"Radio Piranha", nil),
                                           @(ETSPaneViewControllerTypeSecurity)     : NSLocalizedString(@"Sécurité", nil),
                                           @(ETSPaneViewControllerTypeSponsors)     : NSLocalizedString(@"Nos partenaires", nil),
                                           };
    
    self.paneViewControllerIcons = @{
                                           @(ETSPaneViewControllerTypeAbout)        : [UIImage imageNamed:@"ico_about"],
                                           @(ETSPaneViewControllerTypeBandwidth)    : [UIImage imageNamed:@"ico_internet"],
                                           @(ETSPaneViewControllerTypeCalendar)     : [UIImage imageNamed:@"ico_schedule_24x24"],
                                           @(ETSPaneViewControllerTypeComment)      : [UIImage imageNamed:@"ico_comment"],
                                           @(ETSPaneViewControllerTypeCourses)      : [UIImage imageNamed:@"ico_notes"],
                                           @(ETSPaneViewControllerTypeDirectory)    : [UIImage imageNamed:@"ico_bottin"],
                                           @(ETSPaneViewControllerTypeLibrary)      : [UIImage imageNamed:@"ico_library"],
                                           @(ETSPaneViewControllerTypeMoodle)       : [UIImage imageNamed:@"ico_moodle"],
                                           @(ETSPaneViewControllerTypeNews)         : [UIImage imageNamed:@"ico_news"],
                                           @(ETSPaneViewControllerTypeProfile)      : [UIImage imageNamed:@"ico_profil"],
                                           @(ETSPaneViewControllerTypeRadio)        : [UIImage imageNamed:@"ico_radio"],
                                           @(ETSPaneViewControllerTypeSecurity)     : [UIImage imageNamed:@"ico_security"],
                                           @(ETSPaneViewControllerTypeSponsors)     : [UIImage imageNamed:@"ico_partners"],
                                           };
    
    self.paneViewControllerIdentifiers = @{
                                           @(ETSPaneViewControllerTypeAbout)        : @"AboutViewController",
                                           @(ETSPaneViewControllerTypeBandwidth)    : @"BandwidthViewController",
                                           @(ETSPaneViewControllerTypeCalendar)     : @"CalendarViewController",
                                           @(ETSPaneViewControllerTypeComment)      : @"CommentViewController",
                                           @(ETSPaneViewControllerTypeCourses)      : @"CoursesViewController",
                                           @(ETSPaneViewControllerTypeDirectory)    : @"DirectoryViewController",
                                           @(ETSPaneViewControllerTypeLibrary)      : @"WebViewController",
                                           @(ETSPaneViewControllerTypeMoodle)       : @"MoodleViewController",
                                           @(ETSPaneViewControllerTypeNews)         : @"NewsViewController",
                                           @(ETSPaneViewControllerTypeProfile)      : @"ProfileViewController",
                                           @(ETSPaneViewControllerTypeRadio)        : @"RadioViewController",
                                           @(ETSPaneViewControllerTypeSecurity)     : @"SecurityViewController",
                                           @(ETSPaneViewControllerTypeSponsors)     : @"SponsorsViewController",
                                           };
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return 5;
        case 1: return 5;
        case 2: return 3;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ETSMenuCellReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.paneViewControllerTitles[@([self paneViewControllerTypeForIndexPath:indexPath])];
    cell.imageView.image = self.paneViewControllerIcons[@([self paneViewControllerTypeForIndexPath:indexPath])];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:ETSDrawerHeaderReuseIdentifier];
    switch (section)
    {
        case 0: headerView.textLabel.text = [NSLocalizedString(@"Moi", nil) uppercaseString]; break;
        case 1: headerView.textLabel.text = [NSLocalizedString(@"École de technologie supérieure", nil) uppercaseString]; break;
        case 2: headerView.textLabel.text = [NSLocalizedString(@"ApplETS", nil) uppercaseString]; break;
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(ETSMenuTableViewHeader *)view forSection:(NSInteger)section
{
    // Cette fonction est un petit hack pour iOS 8 qui ne supporte pas la fonction load de ETSMenuTableViewHeader.
    view.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    view.textLabel.textColor = [UIColor menuLabelColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return FLT_EPSILON;
}

- (ETSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = 0;
    for (NSUInteger i = 0; i < indexPath.section; i++) {
        row += [self.tableView numberOfRowsInSection:i];
    }
    row += indexPath.row;
    
    return row;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:paneViewControllerType];
}


- (void)transitionToViewController:(ETSPaneViewControllerType)paneViewControllerType
{
    // Close pane if already displaying the pane view controller
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    
    UIViewController *paneViewController = [self.storyboard instantiateViewControllerWithIdentifier:self.paneViewControllerIdentifiers[@(paneViewControllerType)]];
    
    if (!paneViewController) return;
    
    if (paneViewControllerType == ETSPaneViewControllerTypeLibrary)
        ((ETSWebViewViewController *)((UINavigationController *)paneViewController).topViewController).request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ets.mbiblio.ca"]];
    
    if ([paneViewController respondsToSelector:@selector(setManagedObjectContext:)])
        [paneViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
    else if ([paneViewController isKindOfClass:[UINavigationController class]] && [((UINavigationController *)paneViewController).topViewController respondsToSelector:@selector(setManagedObjectContext:)])
        [((UINavigationController *)paneViewController).topViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
    
    if ([paneViewController isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *splitViewController = (UISplitViewController *)paneViewController;
        splitViewController.presentsWithGesture = NO;
        
        id masterViewController = nil;
        if ([splitViewController.viewControllers[0] isKindOfClass:[UINavigationController class]]) {
            masterViewController = ((UINavigationController *)splitViewController.viewControllers[0]).topViewController;
            if ([masterViewController respondsToSelector:@selector(setManagedObjectContext:)])
                [masterViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
        }

        id detailsViewController = nil;
        if ([splitViewController.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            detailsViewController = ((UINavigationController *)splitViewController.viewControllers[1]).topViewController;
            if ([detailsViewController respondsToSelector:@selector(setManagedObjectContext:)])
                [detailsViewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
        }
        splitViewController.delegate = masterViewController;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }

    }
    
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    self.paneRevealLeftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(dynamicsDrawerRevealLeftBarButtonItemTapped:)];
   
    if ([paneViewController isKindOfClass:[UINavigationController class]]) {
        ((UINavigationController *)paneViewController).topViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
    } else if ([paneViewController isKindOfClass:[UISplitViewController class]]) {
        ((UINavigationController *)((UISplitViewController *)paneViewController).viewControllers[0]).topViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
    } else if ([paneViewController isKindOfClass:[UIViewController class]]) {
        paneViewController.navigationItem.leftBarButtonItem = self.paneRevealLeftBarButtonItem;
    }

    [self.dynamicsDrawerViewController setPaneViewController:paneViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

@end
