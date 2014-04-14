//
//  ETSMoodleCourse.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSMoodleElement;

@interface ETSMoodleCourse : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSString * shortname;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *elements;
@end

@interface ETSMoodleCourse (CoreDataGeneratedAccessors)

- (void)addElementsObject:(ETSMoodleElement *)value;
- (void)removeElementsObject:(ETSMoodleElement *)value;
- (void)addElements:(NSSet *)values;
- (void)removeElements:(NSSet *)values;

@end
