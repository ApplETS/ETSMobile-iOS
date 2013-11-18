//
//  NSManagedObject+SetValues.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "NSManagedObject+SetValues.h"

@implementation NSManagedObject (SetValues)

// http://www.cimgf.com/2011/06/02/saving-json-to-core-data/

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter mapping:(NSDictionary *)mapping
{
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes) {
        id value = keyedValues[mapping[attribute]];
        if (value == nil) {
            continue;
        }
        NSAttributeType attributeType = [attributes[attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = @([value integerValue]);
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = @([value doubleValue]);
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]]) && (dateFormatter != nil)) {
            value = [dateFormatter dateFromString:value];
        } else if ((attributeType == NSStringAttributeType) &&  ([value isKindOfClass:[NSNull class]])) {
            value = nil;
        }
        [self setValue:value forKey:attribute];
    }
}

@end
