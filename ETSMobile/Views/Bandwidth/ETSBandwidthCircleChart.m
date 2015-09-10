//
//  ETSBandwidthCircleChart.m
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "ETSBandwidthCircleChart.h"
#import "UIColor+Styles.h"
#import <math.h>

@implementation ETSBandwidthCircleChart

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
}

-(void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat width = 30.0;
    CGFloat radius = (center.x-width/2);
    
    // Drawing background
    UIBezierPath *background = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    [[UIColor grayColor] setStroke];
    background.lineWidth = width;
    [background stroke];
    
    // Drawing used
    if (self.used && self.limit) {
        CGFloat max = (self.used/self.limit) * 2 * M_PI;
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle:-M_PI_2 endAngle:max-M_PI_2 clockwise:YES];
        [[UIColor naviguationBarTintColor] setStroke];
        path.lineWidth = width;
        [path stroke];
    }
}

@end
