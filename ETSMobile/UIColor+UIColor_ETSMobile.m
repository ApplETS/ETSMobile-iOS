//
//  UIColor+UIColor_ETSMobile.m
//  ETSMobile
//
//  Created by Charles Levesque on 2017-03-20.
//  Copyright © 2017 ApplETS. All rights reserved.
//

#import "UIColor+UIColor_ETSMobile.h"

@implementation UIColor (UIColor_ETSMobile)

+ (UIColor *)colorETS
{
    return [UIColor colorWithRed:255.0 / 255.0 green:21.0 / 255.0 blue:15.0 / 255.0 alpha:1.0];
}

+ (UIColor *)success
{
    return [UIColor colorWithRed:34.0 / 255.0 green:187.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
}

+ (UIColor *)error
{
    return [UIColor colorWithRed:187.0 / 255.0 green:33.0 / 255.0 blue:36.0 / 255.0 alpha:1.0];
}

+ (UIColor *)warning
{
    return [UIColor colorWithRed:240.0 / 255.0 green:173.0 / 255.0 blue:78.0 / 255.0 alpha:1.0];
}

@end
