//
//  NSManagedObject+SetValues.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface NSManagedObject (SetValues)
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter mapping:(NSDictionary *)mapping;
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues dateFormatter:(NSDateFormatter *)dateFormatter mapping:(NSDictionary *)mapping ignoredAttributes:(NSArray *)ignoredAttributes;
@end
