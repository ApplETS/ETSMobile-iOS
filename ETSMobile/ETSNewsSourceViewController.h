//
//  ETSNewsSourceViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSNewsSourceViewController : UITableViewController

@property (nonatomic, weak) NSArray *sources;
@property (nonatomic, copy) NSString *savePath;

@end
