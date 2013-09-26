//
//  ETSDetailViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISlider *redSlider;
@property (weak, nonatomic) IBOutlet UISlider *greenSlider;
@property (weak, nonatomic) IBOutlet UISlider *blueSlider;
- (IBAction)changeColor:(id)sender;
@end
