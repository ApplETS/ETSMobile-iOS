//
//  ETSBandwidthCell.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-11.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSBandwidthCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (weak, nonatomic) IBOutlet UILabel *uploadLabel;
@property (weak, nonatomic) IBOutlet UILabel *portLabel;

@end
