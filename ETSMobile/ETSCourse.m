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
        if (![evaluation.ignored boolValue]) {
            sum += [evaluation.weighting floatValue];
        }
    }
    return @(sum);
}


@end
