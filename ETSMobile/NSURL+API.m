//
//  NSURL+API.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-05.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "NSURL+API.h"
#import "NSString+HTML.h"
#import "ETSNewsSource.h"

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

+ (id)URLForEvalEnseignement
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"EvalEnseignement"]];
}

+ (id)URLForDirectory
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Directory"]];
}

+ (id)URLForProfile
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Profile"]];
}

+ (id)URLForMoodle
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"MoodleCourse"]];
}

+ (id)URLForProgram
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Program"]];
}

+ (id)URLForCalendar
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Calendar"]];
}

+ (id)URLForSession
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Session"]];
}

+ (id)URLForNewsWithSources:(NSArray *)sources
{
    NSMutableArray *urls = [NSMutableArray array];
    
    for (ETSNewsSource *source in sources) {
        [urls addObject:[NSString stringWithFormat:@"%@", [source.id urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-7];
    NSDate *lastWeek = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    [offsetComponents setDay:1];
    NSDate *tomorrow = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"News"], [urls componentsJoinedByString:@","], [formatter stringFromDate:lastWeek], [formatter stringFromDate:tomorrow]]];
}

+ (id)URLForComment
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Comment"]];
}

+ (id)URLForBandwidthWithResidence:(NSString *)residence phase:(NSString *)phase
{
    return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"Cooptel_API_V3"], phase, residence]];
}

+ (id)URLForRadio
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    NSDate *today = [calendar dateFromComponents:components];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:3];
    NSDate *nextWeek = [gregorian dateByAddingComponents:offsetComponents toDate:today options:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];

    return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"Radio"], [formatter stringFromDate:today], [formatter stringFromDate:nextWeek]]];
    
 //   return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"Radio"], [formatter stringFromDate:[NSDate date]]]];
}

+ (id)URLForUniversityCalendarStart:(NSDate *)start end:(NSDate *)end
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"UniversityCalendar"], [formatter stringFromDate:start], [formatter stringFromDate:end]]];
//        return [NSURL URLWithString:[NSString stringWithFormat:[NSURL dictionaryFromPlist][@"UniversityCalendar"], [formatter stringFromDate:start]]];
}

+ (id)URLForSponsors
{
    return [NSURL URLWithString:[NSURL dictionaryFromPlist][@"Sponsors"]];
}

@end
