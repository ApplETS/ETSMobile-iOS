//
//  ETSSecurityViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityViewController.h"
#import "MFSideMenu.h"

NSString * const ProcedureTitle = @"Title";
NSString * const ProcedureSummary = @"Summary";
NSString * const ProcedureFile = @"File";

@interface ETSSecurityViewController ()
@property (nonatomic, strong) NSArray *procedures;
@end

@implementation ETSSecurityViewController

@synthesize procedures;
@synthesize mapView;

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Sécurité";
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];

   
    CLLocationCoordinate2D etsCoord = {.latitude =  45.494751265838346, .longitude = -73.56256484985352};
    MKCoordinateSpan span = {.latitudeDelta = 0.0017, .longitudeDelta = 0.005};
    MKCoordinateRegion region = {etsCoord, span};
    [self.mapView setRegion:region];
    
    CLLocationCoordinate2D securiteCoord = {.latitude =  45.49510473488291, .longitude = -73.56269359588623};
    
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = securiteCoord;
    
    annotation.title = @"Sécurité";
    annotation.subtitle = @"1100 Notre-Dame Ouest, local A-0110";
    //annotation.
    
    
    
	[self.mapView addAnnotation:annotation];
    
    [self.mapView selectAnnotation:annotation animated:NO];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Informations personnelles", nil);
    else if (section == 1)  return NSLocalizedString(@"Programme", nil);
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SecurityIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
//    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
//    cell.selectedBackgroundView.backgroundColor = [UIColor menuSelectedCellBackgroundColor];
//    
    cell.textLabel.textColor = [UIColor redColor];
//    cell.textLabel.highlightedTextColor = [UIColor menuHighlightedLabelColor];
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Aujourd'hui", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_today_24x24.png"];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Horaire", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_schedule_24x24.png"];
        }
    }
    
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Nouvelles", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_news.png"];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Bottin", nil);
            cell.imageView.image = [UIImage imageNamed:@"ico_bottin.png"];
        }
    }
    
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, tableView.bounds.size.width, 20)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    
    [headerView addSubview:label];
    
    switch (section)
    {
        case 0: label.text = [NSLocalizedString(@"Test 1", nil) uppercaseString]; break;
        case 1: label.text = [NSLocalizedString(@"Test 2", nil) uppercaseString]; break;
    }
    
    return headerView;
}
>>>>>>> Avancement de Security

@end
