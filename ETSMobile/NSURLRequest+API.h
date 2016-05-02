//
//  NSURLRequest+API.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-06.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ETSCourse.h"

@interface NSURLRequest (API)
+ (id)requestForCourses;
+ (id)requestForProfile;
+ (id)requestForProgram;
+ (id)requestForCalendar:(NSString *)session;
+ (id)requestForSession;
+ (id)requestForMoodleCoursesWithToken:(NSString *)token userid:(NSString *)userid;
+ (id)requestForMoodleCourseDetailWithToken:(NSString *)token courseid:(NSString *)courseid;
+ (id)requestForEvaluationsWithCourse:(ETSCourse *)course;
+ (id)requestForEvalEnseignement;
+ (id)requestForDirectory;
+ (id)requestForNewsWithSources:(NSArray *)sources;
+ (id)requestForRadio;
+ (id)requestForUniversityCalendarStart:(NSDate *)start end:(NSDate *)end;
+ (id)requestForBandwidthWithResidence:(NSString *)residence phase:(NSString *)phase;
+ (id)requestForCommentWithName:(NSString *)name email:(NSString *)email title:(NSString *)title rating:(NSString *)rating comment:(NSString *)comment;
+ (id)requestForSponsors;
@end
