//
//  ETSEvent.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSEvent.h"


@implementation ETSEvent

@dynamic end;
@dynamic id;
@dynamic source;
@dynamic start;
@dynamic title;

- (NSDate *)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.start];
    
    return [calendar dateFromComponents:components];
}

@end
