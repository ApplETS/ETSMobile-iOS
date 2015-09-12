//
//  ETSBandwitdhConfigViewController.m
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSBandwitdhConfigViewController.h"

@interface ETSBandwitdhConfigViewController ()
    @property (nonatomic, copy) NSString *phase;
    @property (nonatomic, copy) NSString *apartment;
@end

@implementation ETSBandwitdhConfigViewController

-(void)viewDidLoad {
    // Load phase and apartment from UserSavedData and place it in the form if any
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    if ([self.apartment length] > 0 && [self.phase integerValue] > 0) {
        self.phaseSegmentedControl.selectedSegmentIndex = [self.phase integerValue] - 1;
        self.apartmentTextField.text = self.apartment;
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.apartmentTextField becomeFirstResponder];
}

- (IBAction)didPressCancelButton:(id)sender {
    // Removing keyboard
    [self.apartmentTextField resignFirstResponder];
    // Closing view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didPressSaveButton:(id)sender {
    
    // Save data if there is any changes
    NSString *phase = [NSString stringWithFormat:@"%d", _phaseSegmentedControl.selectedSegmentIndex + 1];
    NSString *apartment = _apartmentTextField.text;
    
    if (![phase isEqualToString:self.phase] || ![apartment isEqualToString:self.apartment]) {
        if ([phase length] != 0 && [apartment length] != 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:apartment forKey:@"apartment"];
            [userDefaults setObject:phase forKey:@"phase"];
        }
    }
    
    // Closing the view
    [self didPressCancelButton:sender];
}

@end
