//
//  ETSCommentViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 1/20/2014.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCommentViewController.h"

@interface ETSCommentViewController ()
@end

@implementation ETSCommentViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

@end
