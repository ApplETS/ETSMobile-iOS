//
//  ETSSecurityViewController.h
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-02-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import <MapKit/MapKit.h>

@protocol ETSSecurityViewControllerDelegate;

@interface ETSSecurityViewController : UITableViewController

@property (nonatomic, weak) id<ETSSecurityViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@end

@protocol ETSSecurityViewControllerDelegate <NSObject>
- (void)securityViewController:(ETSSecurityViewController *)controller didSelectProcedureWithTitle:(NSString *)title summary:(NSString *)summary file:(NSString *)file;
@end
