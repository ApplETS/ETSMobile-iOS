//
//  ETSCourse.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-10.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCourse.h"
#import "ETSEvaluation.h"


@implementation ETSCourse

@dynamic acronym;
@dynamic credits;
@dynamic grade;
@dynamic group;
@dynamic program;
@dynamic season;
@dynamic session;
@dynamic title;
@dynamic year;
@dynamic order;
@dynamic results;
@dynamic mean;
@dynamic std;
@dynamic median;
@dynamic percentile;
@dynamic evaluations;

- (NSNumber *)totalEvaluationWeighting
{
    float sum = 0;
    for (ETSEvaluation *evaluation in self.evaluations) {
        if (![evaluation.ignored boolValue]) {
            sum += [evaluation.weighting floatValue];
        }
    }
    return [NSNumber numberWithFloat:sum];
}


@end
