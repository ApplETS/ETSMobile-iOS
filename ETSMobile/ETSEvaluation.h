//
//  ETSEvaluation.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-11.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSCourse;

@interface ETSEvaluation : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * mean;
@property (nonatomic, retain) NSNumber * median;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * percentile;
@property (nonatomic, retain) NSNumber * result;
@property (nonatomic, retain) NSNumber * std;
@property (nonatomic, retain) NSString * team;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSNumber * weighting;
@property (nonatomic, retain) NSNumber * ignored;
@property (nonatomic, retain) ETSCourse *course;

@end
