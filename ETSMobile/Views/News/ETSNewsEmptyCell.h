//
//  ETSNewsEmptyCell.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-21.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSNewsEmptyCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end
