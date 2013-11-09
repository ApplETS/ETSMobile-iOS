//
//  ETSCourse.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSCourse : NSManagedObject

@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSString * credits;
@property (nonatomic, retain) NSString * grade;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * program;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSString * session;

@end
