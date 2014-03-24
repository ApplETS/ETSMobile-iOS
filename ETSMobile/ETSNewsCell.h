//
//  ETSNewsCell.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-18.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSNewsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@end
