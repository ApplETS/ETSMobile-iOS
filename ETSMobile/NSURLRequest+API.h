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
+ (id)requestForEvaluationsWithCourse:(ETSCourse *)course;
+ (id)requestForDirectory;

@end
