//
//  ETSRateCell.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 1/21/2014.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSRateCell.h"

@interface ETSRateCell ()
@property (nonatomic, assign, readwrite) NSInteger rating;
@property (nonatomic, strong) NSArray *buttons;
@end

@implementation ETSRateCell

- (void)awakeFromNib
{
    self.buttons = @[self.oneButton, self.twoButton, self.threeButton, self.fourButton, self.fiveButton];
    self.rating = 5;
}

- (IBAction)changeRating:(id)sender
{
    if (sender == self.oneButton) {
        self.rating = 1;
    }
    else if (sender == self.twoButton) {
        self.rating = 2;
    }
    else if (sender == self.threeButton) {
        self.rating = 3;
    }
    else if (sender == self.fourButton) {
        self.rating = 4;
    }
    else if (sender == self.fiveButton) {
        self.rating = 5;
    }
    
    NSInteger i = 1;
    for (UIButton * button in self.buttons) {
        [button setTitleColor:(i <= self.rating) ? [UIColor blackColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        i++;
    }
}

@end
