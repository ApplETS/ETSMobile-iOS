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
        return [NSURL URLWithString:[[NSURL dictionaryFromPlist] objectForKey:@"Courses"]];
    }

    + (id)URLForProfile
    {
        return [NSURL URLWithString:[[NSURL dictionaryFromPlist] objectForKey:@"Profile"]];
    }

@end
