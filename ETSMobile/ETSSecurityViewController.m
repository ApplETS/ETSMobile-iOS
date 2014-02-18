//
//  ETSSecurityViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityViewController.h"
<<<<<<< HEAD
#import "MFSideMenu.h"

NSString * const ProcedureTitle = @"Title";
NSString * const ProcedureSummary = @"Summary";
NSString * const ProcedureFile = @"File";

@interface ETSSecurityViewController ()
//@property (nonatomic, weak) NSArray *procedures;
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
    
    procedures.dataSource = self;
    procedures.delegate = self;
    
   
    CLLocationCoordinate2D etsCoord = {.latitude =  45.494751265838346, .longitude = -73.56256484985352};
    MKCoordinateSpan span = {.latitudeDelta = 0.0017, .longitudeDelta = 0.005};
=======

@implementation ETSSecurityViewController

@synthesize mapView;


- (void)viewDidLoad
{
    self.title = @"Sécurité";
   
    CLLocationCoordinate2D etsCoord = {.latitude =  45.494751265838346, .longitude = -73.56256484985352};
    MKCoordinateSpan span = {.latitudeDelta = 0.0017, .longitudeDelta = 0.001};
>>>>>>> Avancement de Security
    MKCoordinateRegion region = {etsCoord, span};
    [self.mapView setRegion:region];
    
    CLLocationCoordinate2D securiteCoord = {.latitude =  45.49510473488291, .longitude = -73.56269359588623};
    
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = securiteCoord;
<<<<<<< HEAD
    
    annotation.title = @"Sécurité";
    annotation.subtitle = @"1100 Notre-Dame Ouest, local A-0110";
    //annotation.
    
    
    
	[self.mapView addAnnotation:annotation];
    
    [self.mapView selectAnnotation:annotation animated:NO];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ProcedureCell";
    UITableViewCell *thisCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSArray *procedures = [NSArray arrayWithObjects:@"Appel à la bombe", @"Colis suspect", @"Incendie", @"Odeur suspect", @"Panne d'ascenceur", @"Panne électrique", @"Personne armée", @"Urgence médicale", nil];
    
    NSArray *imageProcedures = [NSArray arrayWithObjects:@"bomb.png", @"Arme1.png", @"incendie.png", @"incendie.png", @"incendie.png", @"electrique.png", @"arme.png", @"coeur.png", nil];
    
    if(thisCell==nil)
    {
        thisCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    thisCell.textLabel.text = [procedures objectAtIndex:indexPath.row];
    thisCell.imageView.image = [UIImage imageNamed:[imageProcedures objectAtIndex:indexPath.row]];
    thisCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return thisCell;
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
////    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
////    cell.selectedBackgroundView.backgroundColor = [UIColor menuSelectedCellBackgroundColor];
////
//    cell.textLabel.textColor = [UIColor redColor];
////    cell.textLabel.highlightedTextColor = [UIColor menuHighlightedLabelColor];
//
//    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
//
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            cell.textLabel.text = NSLocalizedString(@"Aujourd'hui", nil);
//            cell.imageView.image = [UIImage imageNamed:@"ico_today_24x24.png"];
//        }
//        else if (indexPath.row == 1) {
//            cell.textLabel.text = NSLocalizedString(@"Horaire", nil);
//            cell.imageView.image = [UIImage imageNamed:@"ico_schedule_24x24.png"];
//        }
//    }
//
//    else if (indexPath.section == 1) {
//        if (indexPath.row == 0) {
//            cell.textLabel.text = NSLocalizedString(@"Nouvelles", nil);
//            cell.imageView.image = [UIImage imageNamed:@"ico_news.png"];
//        }
//        else if (indexPath.row == 1) {
//            cell.textLabel.text = NSLocalizedString(@"Bottin", nil);
//            cell.imageView.image = [UIImage imageNamed:@"ico_bottin.png"];
//        }
//    }
//
//    return cell;
}



//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//

//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)       return NSLocalizedString(@"Informations personnelles", nil);
//    else if (section == 1)  return NSLocalizedString(@"Programme", nil);
//    return nil;
//}
//
//
//
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
//    headerView.backgroundColor = [UIColor lightGrayColor];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, tableView.bounds.size.width, 20)];
//    label.textColor = [UIColor blackColor];
//    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
//    
//    [headerView addSubview:label];
//    
//    switch (section)
//    {
//        case 0: label.text = [NSLocalizedString(@"Test 1", nil) uppercaseString]; break;
//        case 1: label.text = [NSLocalizedString(@"Test 2", nil) uppercaseString]; break;
//    }
//    
//    return headerView;
//}
=======
    annotation.title = @"Sécurité";
    annotation.subtitle = @"1100 Notre-Dame Ouest, local A-0110";
    
	[self.mapView addAnnotation:annotation];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 3;
    //FIXME : à corriger lorsque l'on aura les infos sur la section Programme
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Test 1", nil);
    else if (section == 1)  return NSLocalizedString(@"Test 2", nil);
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    //FIXME : à corriger lorsque l'on aura les infos sur la section Programme
    if (indexPath.section == 1) return;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    ETSProfile *profile = nil;
//    if ([self.fetchedResultsController.fetchedObjects count] > 0) profile = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Prénom", nil);
        cell.detailTextLabel.text = @"lala";
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Nom de famille", nil);
        cell.detailTextLabel.text = @"lulu";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Code permanent", nil);
        cell.detailTextLabel.text = @"Prénom";
    }

}
>>>>>>> Avancement de Security

@end
