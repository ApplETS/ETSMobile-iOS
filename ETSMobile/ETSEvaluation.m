//
//  ETSEvaluation.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-11.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//
#import "ETSEvaluation.h"
#import "ETSCourse.h"

@implementation ETSEvaluation

#if !TARGET_WATCH_EXTENSION
@dynamic date;
@dynamic mean;
@dynamic median;
@dynamic name;
@dynamic percentile;
@dynamic result;
@dynamic std;
@dynamic team;
@dynamic total;
@dynamic weighting;
@dynamic ignored;
@dynamic course;
#endif

- (instancetype)initWithDictionary:(NSDictionary<NSString *,id> *)dictionary
{
    self = [super init];
    if (self) {
        NSArray<NSString *> *includedProperties = [self propertyList];
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
        
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
        
        free(properties);
    }
    return self;
}

- (NSDictionary<NSString *,id> *)dictionary
{
    NSMutableDictionary<NSString *, id> *dict = [NSMutableDictionary new];
    unsigned int propertyCount;
    NSArray<NSString *> *includedProperties = [self propertyList];
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
    return dict;
}

- (NSArray<NSString *> *)propertyList
{
    return @[
             @"date",
             @"mean",
             @"median",
             @"name",
             @"percentile",
             @"result",
             @"std",
             @"team",
             @"total",
             @"weighting",
             @"ignored"
             ];
}

@end
