//
//  ETSCourse.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-10.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCourse.h"
#import "ETSEvaluation.h"
#import "ETSEvaluation.h"

@implementation ETSCourse

#if !TARGET_WATCH_EXTENSION
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
#endif

- (instancetype)initWithDictionary:(NSDictionary<NSString *,id> *)dictionary
{
    self = [super self];
    if (self) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
        NSArray<NSString *> *includedProperties = [self propertyList];
        
        for (int i = 0; i < propertyCount; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
            bool propertyIsIncluded = [includedProperties containsObject:propertyName];
            
            if (dictionary[propertyName] != nil && propertyIsIncluded) {
                if ([dictionary[propertyName] isKindOfClass:[NSString class]] && [dictionary[propertyName] isEqualToString:@""]) {
                    [self setValue:nil forKey:propertyName];
                } else {
                    [self setValue:dictionary[propertyName] forKey:propertyName];
                }
            }
        }
        
        NSArray<NSDictionary<NSString *, id> *> *evaluationDictionaries = dictionary[@"evaluations"];
        
        if (evaluationDictionaries != nil) {
            NSMutableSet *evaluations = [NSMutableSet new];
            
            for (NSDictionary<NSString *, id> *evalDict in evaluationDictionaries) {
                [evaluations addObject:[[ETSEvaluation alloc] initWithDictionary:evalDict]];
            }
            
            [self setValue:evaluations forKey:@"evaluations"];
        }
        
        free(properties);
    }
    return self;
}

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

- (NSDictionary<NSString *,id> *)dictionary
{
    NSMutableArray<NSDictionary<NSString *, id> *> *evaluations = [NSMutableArray new];
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary new];
    unsigned int propertyCount;
    NSArray<NSString *> *includedProperties = [self propertyList];
    
    for (ETSEvaluation *evaluation in self.evaluations) {
        [evaluations addObject:[evaluation dictionary]];
    }
    
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSASCIIStringEncoding];
        id propertyValue = [self valueForKey:propertyName];
        bool propertyIsIncluded = [includedProperties containsObject:propertyName];
        
        if (propertyValue != nil && propertyIsIncluded) {
            dict[propertyName] = propertyValue;
        }
    }
    
    free(properties);
    
    dict[@"evaluations"] = evaluations;
    return dict;
}

- (NSArray<NSString *> *)propertyList
{
    return @[
             @"acronym",
             @"credits",
             @"grade",
             @"group",
             @"id",
             @"mean",
             @"median",
             @"order",
             @"percentile",
             @"program",
             @"results",
             @"season",
             @"session",
             @"std",
             @"title",
             @"year",
             @"resultOn100"
             ];
}

@end
