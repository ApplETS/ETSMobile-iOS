//
//  ETSMenuViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-07-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSMenuViewController.h"
#import "ETSWebViewViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "UIColor+Styles.h"
#import "ETSAppDelegate.h"
#import "ETSTableViewController.h"

NSString * const kStoryboardNewsViewController              = @"NewsViewController";
NSString * const kStoryboardAuthenticationViewController    = @"AuthenticationViewController";
NSString * const kStoryboardCoursesViewController           = @"CoursesViewController";
NSString * const kStoryboardProfileViewController           = @"ProfileViewController";
NSString * const kStoryboardMoodleViewController            = @"MoodleViewController";
NSString * const kStoryboardCalendarViewController          = @"CalendarViewController";
NSString * const kStoryboardDirectoryViewController         = @"DirectoryViewController";
NSString * const kStoryboardLibraryViewController           = @"WebViewController";
NSString * const kStoryboardRadioViewController             = @"RadioViewController";
NSString * const kStoryboardSecurityViewController          = @"SecurityViewController";
NSString * const kStoryboardBandwidthViewController         = @"BandwidthViewController";
NSString * const kStoryboardCommentViewController           = @"CommentViewController";
NSString * const kStoryboardAboutViewController             = @"AboutViewController";
NSString * const kStoryboardSponsorsViewController          = @"SponsorsViewController";

typedef NS_ENUM(NSInteger, ETSMenuMe)
{
    //ETSMenuMeToday,
    ETSMenuMeSchedule,
    ETSMenuMeCourse,
    //ETSMenuMeInternship,
    ETSMenuMeProfile,
    ETSMenuMeMoodle,
    ETSMenuMeBandwidth
};

typedef NS_ENUM(NSInteger, ETSMenuUniversity)
{
    ETSMenuUniversityNews,
    ETSMenuUniversityDirectory,
    ETSMenuUniversityLibrary,
    ETSMenuUniversityRadio,
    ETSMenuUniversitySecurity
};

typedef NS_ENUM(NSInteger, ETSMenuApplETS)
{
    ETSMenuApplETSComments,
    ETSMenuApplETSAbout,
    ETSMenuApplETSSponsors
};

@implementation ETSMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor menuSeparatorColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.parentViewController;
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
    static NSString *CellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor menuSelectedCellBackgroundColor];
    
    cell.backgroundColor = [UIColor menuCellBackgroundColor];

    cell.textLabel.textColor = [UIColor menuLabelColor];
    cell.textLabel.highlightedTextColor = [UIColor menuHighlightedLabelColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
    if (indexPath.section == 0) {
  /*      if (indexPath.row == ETSMenuMeToday) {
            cell.textLabel.text = NSLocalizedString(@"Aujourd'hui", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_aujourdhui.png"];
        }
        else*/ if (indexPath.row == ETSMenuMeSchedule) {
            cell.textLabel.text = NSLocalizedString(@"Horaire", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_schedule_24x24.png"];
        }
        else if (indexPath.row == ETSMenuMeCourse) {
            cell.textLabel.text = NSLocalizedString(@"Notes", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_notes.png"];
        }
/*        else if (indexPath.row == ETSMenuMeInternship) {
            cell.textLabel.text = NSLocalizedString(@"Stages", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_stage.png"];
        }*/
        else if (indexPath.row == ETSMenuMeProfile) {
            cell.textLabel.text = NSLocalizedString(@"Profil", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_profil.png"];
        }
        else if (indexPath.row == ETSMenuMeMoodle) {
            cell.textLabel.text = NSLocalizedString(@"Moodle", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_moodle.png"];
        }
        else if (indexPath.row == ETSMenuMeBandwidth) {
            cell.textLabel.text = NSLocalizedString(@"Bande passante", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_internet.png"];
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == ETSMenuUniversityNews) {
            cell.textLabel.text = NSLocalizedString(@"Nouvelles", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_news.png"];
        }
        else if (indexPath.row == ETSMenuUniversityDirectory) {
            cell.textLabel.text = NSLocalizedString(@"Bottin", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_bottin.png"];
        }
        else if (indexPath.row == ETSMenuUniversityLibrary) {
            cell.textLabel.text = NSLocalizedString(@"Bibliothèque", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_library.png"];
        }
        else if (indexPath.row == ETSMenuUniversityRadio) {
            cell.textLabel.text = NSLocalizedString(@"Radio Piranha", nil);
             cell.imageView.image = [UIImage imageNamed:@"ico_radio.png"];
        }
        else if (indexPath.row == ETSMenuUniversitySecurity) {
            cell.textLabel.text = NSLocalizedString(@"Sécurité", nil);
             cell.imageView.image = [UIImage imageNamed:@"ico_security.png"];
        }
    }
    
    else if (indexPath.section == 2) {
        if (indexPath.row == ETSMenuApplETSComments) {
            cell.textLabel.text = NSLocalizedString(@"Problème ou commentaire?", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_comment.png"];
        }
        else if (indexPath.row == ETSMenuApplETSAbout) {
            cell.textLabel.text = NSLocalizedString(@"À propos d'ÉTSMobile", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_about.png"];
        }
        else if (indexPath.row == ETSMenuApplETSSponsors) {
            cell.textLabel.text = NSLocalizedString(@"Nos partenaires", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_partners.png"];
        }
    }

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor menuSectionBackgroundColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, tableView.bounds.size.width, 20)];
    label.textColor = [UIColor menuLabelColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    
    [headerView addSubview:label];
    
    switch (section)
    {
        case 0: label.text = [NSLocalizedString(@"Moi", nil) uppercaseString]; break;
        case 1: label.text = [NSLocalizedString(@"École de technologie supérieure", nil) uppercaseString]; break;
        case 2: label.text = [NSLocalizedString(@"ApplETS", nil) uppercaseString]; break;
    }
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (indexPath.section == 0) {
/*        if (indexPath.row == ETSMenuMeToday) {

        }
        else*/ if (indexPath.row == ETSMenuMeSchedule) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCalendarViewController];
        }
        else if (indexPath.row == ETSMenuMeCourse) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCoursesViewController];
        }
/*        else if (indexPath.row == ETSMenuMeInternship) {
            viewController = [self.storyboard instantiateAuthenticationViewController];
        }*/
        else if (indexPath.row == ETSMenuMeProfile) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardProfileViewController];
        }
        else if (indexPath.row == ETSMenuMeMoodle) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardMoodleViewController];
        }
        else if (indexPath.row == ETSMenuMeBandwidth) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardBandwidthViewController];
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == ETSMenuUniversityNews) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardNewsViewController];
        }
        else if (indexPath.row == ETSMenuUniversityDirectory) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardDirectoryViewController];
        }
        else if (indexPath.row == ETSMenuUniversityLibrary) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardLibraryViewController];
            ((ETSWebViewViewController *)viewController).initialRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ets.mbiblio.ca"]];
        }
        else if (indexPath.row == ETSMenuUniversityRadio) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardRadioViewController];
        }
        else if (indexPath.row == ETSMenuUniversitySecurity) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardSecurityViewController];
        }
    }
    
    else if (indexPath.section == 2) {
        if (indexPath.row == ETSMenuApplETSComments) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardCommentViewController];
        }
        else if (indexPath.row == ETSMenuApplETSAbout) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAboutViewController];
        }
        else if (indexPath.row == ETSMenuApplETSSponsors) {
            viewController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardSponsorsViewController];
        }
    }
    
    if (!viewController) return;
    
    if ([viewController respondsToSelector:@selector(setManagedObjectContext:)])
        [viewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
    
    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    [navigationController.navigationBar setTranslucent:YES];
    [navigationController.toolbar setTranslucent:YES];
    NSArray *controllers = @[viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

@end
