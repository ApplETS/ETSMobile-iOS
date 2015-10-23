//
//  NSDate+Timezone.m
//  ETSMobile
//
//  Created by Maxime Mongeau on 2015-10-22.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import "NSDate+Timezone.h"

@implementation NSDate (Timezone)

- (NSDate *) toUTCTime {
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end
