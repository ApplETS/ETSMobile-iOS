//
//  ETSEvent.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-05.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSEvent.h"


@implementation ETSEvent

@dynamic end;
@dynamic id;
@dynamic start;
@dynamic title;
@dynamic source;

- (NSDate *)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self.start];
    
    return [calendar dateFromComponents:components];
}

@end
