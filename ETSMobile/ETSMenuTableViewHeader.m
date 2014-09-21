//
//  ETSMenuTableViewHeader.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-16.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSMenuTableViewHeader.h"
#import "UIColor+Styles.h"

@implementation ETSMenuTableViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *backgoundView = [UIView new];
        backgoundView.backgroundColor = [UIColor menuSectionBackgroundColor];
        self.backgroundView = backgoundView;
    }
    return self;
}

+ (void)load
{
    id labelAppearance = [UILabel appearanceWhenContainedIn:[self class], nil];
    [labelAppearance setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
    [labelAppearance setTextColor:[UIColor menuLabelColor]];
}

@end
