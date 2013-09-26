//
//  UIColor+Styles.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-25.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "UIColor+Styles.h"

@implementation UIColor (Styles)

+ (UIColor *)menuCellBackgroundColor
{
    return [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1];
}

+ (UIColor *)menuSelectedCellBackgroundColor
{
//    return [UIColor colorWithRed:202.0f/255.0f green:28.0f/255.0f blue:38.0f/255.0f alpha:1];
    return [UIColor colorWithRed:203.0f/255.0f green:51.0f/255.0f blue:59.0f/255.0f alpha:1];
}

+ (UIColor *)menuSeparatorColor
{
    return [UIColor colorWithRed:68.0f/255.0f green:68.0f/255.0f blue:68.0f/255.0f alpha:1];
}

+ (UIColor *)menuLabelColor
{
    return [UIColor colorWithRed:128.0f/255.0f green:128.0f/255.0f blue:128.0f/255.0f alpha:1];
}

+ (UIColor *)menuHighlightedLabelColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)menuSectionBackgroundColor
{
    return [UIColor colorWithRed:33.0f/255.0f green:33.0f/255.0f blue:33.0f/255.0f alpha:1];
}

+ (UIColor *)naviguationBarTintColor
{
    return [UIColor colorWithRed:190.0f/255.0f green:0.0f/255.0f blue:10.0f/255.0f alpha:1];
}

@end
