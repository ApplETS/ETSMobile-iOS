//
//  ETSProfileViewController.h
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "ETSProfile.h"

@interface ETSProfileViewController : ETSTableViewController <ETSConnectionDelegate>
@property (nonatomic, strong) ETSProfile *profile;
@end
