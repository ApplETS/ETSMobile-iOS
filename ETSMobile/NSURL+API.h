//
//  NSURL+API.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-05.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (API)
+ (id)URLForCourses;
+ (id)URLForProfile;
+ (id)URLForMoodle;
+ (id)URLForProgram;
+ (id)URLForCalendar;
+ (id)URLForSession;
+ (id)URLForEvaluations;
+ (id)URLForEvalEnseignement;
+ (id)URLForDirectory;
+ (id)URLForRadio;
+ (id)URLForUniversityCalendarStart:(NSDate *)start end:(NSDate *)end;
+ (id)URLForNewsWithSources:(NSArray *)sources;
+ (id)URLForComment;
+ (id)URLForBandwidthWithResidence:(NSString *)residence phase:(NSString *)phase;
+ (id)URLForSponsors;
@end
