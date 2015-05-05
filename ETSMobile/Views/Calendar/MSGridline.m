//
//  MSGridlineCollectionReusableView.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSGridline.h"

@implementation MSGridline

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:215/255.0f green:215/255.0f blue:215/255.0f alpha:1.0f];
    }
    return self;
}

@end
