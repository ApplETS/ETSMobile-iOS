//
//  MSCurrentTimeIndicator.m
//  Example
//
//  Created by Eric Horacek on 2/27/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSCurrentTimeIndicator.h"
#import "UIColor+HexString.h"

@interface MSCurrentTimeIndicator ()

@property (nonatomic, strong) UILabel *time;
@property (nonatomic, retain) NSTimer *minuteTimer;

@end

@implementation MSCurrentTimeIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.time = [UILabel new];
        self.time.font = [UIFont boldSystemFontOfSize:10.0];
        self.time.textColor = [UIColor colorWithHexString:@"fd3935"];
        [self addSubview:self.time];
        /*
        [self.time makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerY);
            make.right.equalTo(self.right).offset(-5.0);
        }]; */
        
        self.time.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:@[
                               
                               //view1 constraints
                               [NSLayoutConstraint constraintWithItem:self.time
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.time
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-5]]
         ];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
        NSDate *nextMinuteBoundary = [calendar dateFromComponents:components];
        
        self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:self selector:@selector(minuteTick:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
        
        [self updateTime];
    }
    return self;
}

#pragma mark - MSCurrentTimeIndicator

- (void)minuteTick:(id)sender
{
    [self updateTime];
}

- (void)updateTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"HH:mm"];
    self.time.text = [dateFormatter stringFromDate:[NSDate date]];
    [self.time sizeToFit];
}

@end
