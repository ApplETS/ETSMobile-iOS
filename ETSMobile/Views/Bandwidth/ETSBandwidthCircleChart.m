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
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat width = 30.0;
    CGFloat radius = MIN(center.x, center.y)-width;
    
    if (self.used && self.limit) {
        // Drawing background
        UIBezierPath *background = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle:0 endAngle:2*M_PI clockwise:YES];
        [[UIColor grayColor] setStroke];
        background.lineWidth = width;
        [background stroke];
        
        // Drawing used
        CGFloat max = (self.used/self.limit);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius: radius startAngle: [self getInitialAngle] endAngle:[self getAngleForRate:max] clockwise:YES];
        [[UIColor naviguationBarTintColor] setStroke];
        path.lineWidth = width;
        [path stroke];
    }
    
    // Drawing ideal quota marker
    if (self.limit && self.ideal) {
        CGPoint beginPoint = [self getCoordFromPolarWithRadius:radius-width withAngle:[self getAngleForRate:self.ideal/self.limit] withCenter:center];
        CGPoint endPoint = [self getCoordFromPolarWithRadius:radius+width withAngle:[self getAngleForRate:self.ideal/self.limit] withCenter:center];
        
        UIBezierPath* marker = [UIBezierPath bezierPath];
        [marker moveToPoint:beginPoint];
        [marker addLineToPoint:endPoint];
        
        [[self darkerColorForColor:[UIColor naviguationBarTintColor] amplitude:0.2] setStroke];
        marker.lineWidth = 2;
        [marker stroke];
    }
}

-(CGFloat)getAngleForRate:(CGFloat)rate {
    return (rate*2*M_PI)-M_PI_2;
}

-(CGFloat)getInitialAngle {
    return [self getAngleForRate:0];
}

-(CGPoint)getCoordFromPolarWithRadius:(CGFloat)radius withAngle:(CGFloat)angle withCenter:(CGPoint)center {
    return CGPointMake(center.x + radius*cos(angle), center.y + radius*sin(angle));
}

- (UIColor *)darkerColorForColor:(UIColor *)c amplitude:(CGFloat)amp
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - amp, 0.0)
                               green:MAX(g - amp, 0.0)
                                blue:MAX(b - amp, 0.0)
                               alpha:a];
    return nil;
}

@end
