//
//  ETSSecurityViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityViewController.h"

@implementation ETSSecurityViewController

@synthesize mapView;


- (void)viewDidLoad
{
    self.title = @"Sécurité";
   
    CLLocationCoordinate2D etsCoord = {.latitude =  45.494751265838346, .longitude = -73.56256484985352};
    MKCoordinateSpan span = {.latitudeDelta = 0.0017, .longitudeDelta = 0.001};
    MKCoordinateRegion region = {etsCoord, span};
    [self.mapView setRegion:region];
    
    CLLocationCoordinate2D securiteCoord = {.latitude =  45.49510473488291, .longitude = -73.56269359588623};
    
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = securiteCoord;
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

@end
