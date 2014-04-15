//
//  MSDayColumnHeaderBackground.m
//  Example
//
//  Created by Eric Horacek on 2/28/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSDayColumnHeaderBackground.h"

@implementation MSDayColumnHeaderBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:0.95f];
    }
    return self;
}

@end
