//
//  ETSBandwidthViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-12-31.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"

@interface ETSBandwidthViewController : ETSTableViewController
@property (nonatomic, weak) IBOutlet UISegmentedControl *phaseSegmentedControl;
@property (nonatomic, weak) IBOutlet UITextField        *apartmentTextField;
@end
