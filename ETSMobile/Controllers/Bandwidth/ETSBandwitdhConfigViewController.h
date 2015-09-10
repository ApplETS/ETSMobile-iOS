//
//  ETSBandwitdhConfigViewController.h
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSBandwitdhConfigViewController: UITableViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *phaseSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *apartmentTextField;

@end
