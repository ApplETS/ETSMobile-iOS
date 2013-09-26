//
//  UIStoryboard+ViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-25.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "UIStoryboard+ViewController.h"

@implementation UIStoryboard (ViewController)

- (id)instantiateNewsViewController
{
    return [self instantiateViewControllerWithIdentifier:@"NewsViewController"];
}

@end
