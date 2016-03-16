//
//  ETSEvaluationCell.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-27.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSEvaluationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *meanLabel;
@property (weak, nonatomic) IBOutlet UILabel *medianLabel;
@property (weak, nonatomic) IBOutlet UILabel *stdLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentileLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightingLabel;

@end
