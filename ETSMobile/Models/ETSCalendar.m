//
//  ETSCalendar.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSCalendar.h"


@implementation ETSCalendar

@dynamic course;
@dynamic end;
@dynamic id;
@dynamic room;
@dynamic session;
@dynamic start;
@dynamic summary;
@dynamic title;

- (NSDate *)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.start];
    
    return [calendar dateFromComponents:components];
}

@end
