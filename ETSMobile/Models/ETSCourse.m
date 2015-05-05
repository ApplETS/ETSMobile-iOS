//
//  ETSCourse.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSCourse.h"
#import "ETSEvaluation.h"


@implementation ETSCourse

@dynamic acronym;
@dynamic credits;
@dynamic grade;
@dynamic group;
@dynamic id;
@dynamic mean;
@dynamic median;
@dynamic order;
@dynamic percentile;
@dynamic program;
@dynamic results;
@dynamic season;
@dynamic session;
@dynamic std;
@dynamic title;
@dynamic year;
@dynamic resultOn100;
@dynamic evaluations;

- (NSNumber *)totalEvaluationWeighting
{
    float sum = 0;
    for (ETSEvaluation *evaluation in self.evaluations) {
        if (![evaluation.ignored boolValue] && [evaluation.mean floatValue] > 0) {
            sum += [evaluation.weighting floatValue];
        }
    }
    return @(sum);
}

@end
