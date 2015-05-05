//
//  ETSMoodleCourse.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSMoodleElement;

@interface ETSMoodleCourse : NSManagedObject

@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSString * shortname;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSSet *elements;
@end

@interface ETSMoodleCourse (CoreDataGeneratedAccessors)

- (void)addElementsObject:(ETSMoodleElement *)value;
- (void)removeElementsObject:(ETSMoodleElement *)value;
- (void)addElements:(NSSet *)values;
- (void)removeElements:(NSSet *)values;

@end
