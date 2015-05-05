//
//  ETSAboutViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSAboutViewController.h"

@implementation ETSAboutViewController

<<<<<<< HEAD
<<<<<<< HEAD
=======
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    #ifdef __USE_BUGSENSE
    [[Mint sharedInstance] leaveBreadcrumb:@"ABOUT_VIEWCONTROLLER"];
    #endif
}

>>>>>>> Retrait de TestFlight.
=======
>>>>>>> Mise à jour de 2.0.3 vers 2.1
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.8
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.aboutLabel.alpha = 1;
                     }
                     completion:nil];
}

@end
