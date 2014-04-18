//
//  ETSMenuCell.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-16.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSMenuCell.h"
#import "UIColor+Styles.h"

@implementation ETSMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = [UIColor menuSelectedCellBackgroundColor];
        
        self.backgroundColor = [UIColor menuCellBackgroundColor];
        
        self.textLabel.textColor = [UIColor menuLabelColor];
        self.textLabel.highlightedTextColor = [UIColor menuHighlightedLabelColor];
        
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
