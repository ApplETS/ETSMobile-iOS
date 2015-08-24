//
//  MSDayColumnHeader.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSDayColumnHeader.h"

@interface MSDayColumnHeader ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *titleBackground;

@end

@implementation MSDayColumnHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleBackground = [UIView new];
        self.titleBackground.layer.cornerRadius = nearbyintf(15.0);
        [self addSubview:self.titleBackground];
        
        self.backgroundColor = [UIColor clearColor];
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleBackground.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.title];
        
        [self addConstraints:@[
                               
                               //view1 constraints
                               [NSLayoutConstraint constraintWithItem:self.titleBackground
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.title
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:-6],
                               [NSLayoutConstraint constraintWithItem:self.titleBackground
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.title
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:-12],
                               [NSLayoutConstraint constraintWithItem:self.titleBackground
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.title
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-12],
                               [NSLayoutConstraint constraintWithItem:self.titleBackground
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.title
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:-4],
                               
                               [NSLayoutConstraint constraintWithItem:self.title
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.title
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1.0
                                                             constant:0],
                               ]
         ];
        
    }
    return self;
}

- (void)setDay:(NSDate *)day
{
    _day = day;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    self.title.text = [dateFormatter stringFromDate:day];
    [self setNeedsLayout];
}

- (void)setCurrentDay:(BOOL)currentDay
{
    _currentDay = currentDay;
    
    if (currentDay) {
        self.title.textColor = [UIColor colorWithRed:253/255.0f green:57/255.0f blue:53/255.0f alpha:1];
        self.title.font = [UIFont boldSystemFontOfSize:16.0];
    } else {
        self.title.font = [UIFont systemFontOfSize:16.0];
        self.title.textColor = [UIColor blackColor];
    }
}

@end
