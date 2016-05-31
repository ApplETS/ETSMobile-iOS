//
//  ETSSecurityViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityViewController.h"
#import "ETSSecurityDetailViewController.h"

#import <Crashlytics/Crashlytics.h>

NSString * const kProcedureTitle = @"Title";
NSString * const kProcedureSummary = @"Summary";
NSString * const kProcedureFile = @"File";

@interface ETSSecurityViewController ()
@property (nonatomic, strong) NSArray *procedures;
@end

@implementation ETSSecurityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationCoordinate2D etsCoord = {.latitude =  45.494751265838346, .longitude = -73.56256484985352};
    MKCoordinateSpan span = {.latitudeDelta = 0.0017, .longitudeDelta = 0.005};
    MKCoordinateRegion region = {etsCoord, span};
    [self.mapView setRegion:region];
    
    CLLocationCoordinate2D securiteCoord = {.latitude =  45.49510473488291, .longitude = -73.56269359588623};
    
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = securiteCoord;
    
    annotation.title = @"Sécurité";
    annotation.subtitle = @"1100 Notre-Dame Ouest, local A-0110";
    
	[self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:NO];
    
    self.procedures = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"SecuritySources.plist"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Security"
                        contentType:@"Security"
                          contentId:@"ETS-Security"
                   customAttributes:@{}];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[ETSSecurityDetailViewController class]]) {
        ETSSecurityDetailViewController *viewController = [segue destinationViewController];
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *procedure = self.procedures[indexPath.row];
        viewController.summary = procedure[kProcedureSummary];
        viewController.title = procedure[kProcedureTitle];
        viewController.file = procedure[kProcedureFile];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 2 : [self.procedures count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"callCell"];
        
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Appel d’urgence", nil);
            cell.detailTextLabel.text = @"514 396-8900";
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"À l’interne", nil);
            cell.detailTextLabel.text = @"Poste 55";
        }
    }
    
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"procedureCell"];
        cell.textLabel.text = self.procedures[indexPath.row][kProcedureTitle];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if      (section == 0)  return NSLocalizedString(@"Joindre la sécurité", nil);
    else if (section == 1)  return NSLocalizedString(@"Procédures d’urgence", nil);
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSString *phoneNumber = @"telprompt://5143968900";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } else if (indexPath.section > 0 && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {

        NSDictionary *procedure = self.procedures[indexPath.row];
        [self.delegate securityViewController:self didSelectProcedureWithTitle:procedure[kProcedureTitle] summary:procedure[kProcedureSummary] file:procedure[kProcedureFile]];
    }
}

@end
