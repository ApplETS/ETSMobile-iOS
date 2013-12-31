//
//  NSURL+API.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-05.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "NSURL+API.h"

@interface NSURL (API_PRIVATE)
+ (NSDictionary *)dictionaryFromPlist;
@end

@implementation NSURL (API_PRIVATE)
+ (NSDictionary *)dictionaryFromPlist
{
    return [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ETSAPIURL" ofType:@"plist"]];
}
@end

@implementation NSURL (API)

+ (id)URLForCourses
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Courses"]];
}

+ (id)URLForEvaluations
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Evaluations"]];
}

+ (id)URLForDirectory
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Directory"]];
}

+ (id)URLForProfile
{
    return [NSURL URLWithString:[[NSURL dictionaryFromPlist] objectForKey:@"Profile"]];
}

+ (id)URLForRadio
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *tomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddMMyyyy"];

    return [NSURL URLWithString:[NSString stringWithFormat:[[NSURL dictionaryFromPlist] objectForKey:@"Radio"], [formatter stringFromDate:[NSDate date]], [formatter stringFromDate:tomorrow]]];
}

@end
