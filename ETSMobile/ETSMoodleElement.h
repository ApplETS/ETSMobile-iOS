//
//  ETSMoodleElement.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSMoodleCourse;

@interface ETSMoodleElement : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * parentid;
@property (nonatomic, retain) NSString * header;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSNumber * visible;
@property (nonatomic, retain) ETSMoodleCourse *course;

@end
