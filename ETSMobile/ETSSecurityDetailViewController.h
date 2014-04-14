//
//  ETSSecurityDetailViewController.h
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-04-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSSecurityViewController.h"

@interface ETSSecurityDetailViewController : UIViewController <ETSSecurityViewControllerDelegate>

@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *file;

@end
