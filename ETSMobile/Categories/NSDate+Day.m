//
//  NSDate+Day.m
//  test2
//
//  Created by Jean-Philippe Martin on 2014-04-02.
//  Copyright (c) 2014 Jean-Philippe Martin. All rights reserved.
//

#import "NSDate+Day.h"

@implementation NSDate (Day)

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    
    return [calendar dateFromComponents:components];
}

@end
