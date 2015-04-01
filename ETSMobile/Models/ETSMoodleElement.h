//
//  ETSMoodleElement.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSMoodleCourse;

@interface ETSMoodleElement : NSManagedObject

@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * parentid;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) ETSMoodleCourse *course;

@end
