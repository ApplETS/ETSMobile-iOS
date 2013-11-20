//
//  ETSProfileViewController.h
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSConnection.h"

@interface ETSProfileViewController : UITableViewController <ETSConnectionDelegate>
    @property (nonatomic, copy)   NSString *entityName;
    @property (nonatomic, strong) NSURLRequest *request;

    @property (strong, nonatomic) ETSConnection *connection;
@end
