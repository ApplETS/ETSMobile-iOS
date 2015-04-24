//
//  ETSCourse.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-27.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ETSEvaluation;

@interface ETSCourse : NSManagedObject

@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSString * credits;
@property (nonatomic, retain) NSString * grade;
@property (nonatomic, retain) NSString * group;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * mean;
@property (nonatomic, retain) NSNumber * median;
@property (nonatomic, retain) NSString * order;
@property (nonatomic, retain) NSNumber * percentile;
@property (nonatomic, retain) NSString * program;
@property (nonatomic, retain) NSNumber * results;
@property (nonatomic, retain) NSNumber * season;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSNumber * std;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * resultOn100;
@property (nonatomic, retain) NSSet *evaluations;

- (NSNumber *)totalEvaluationWeighting;
@end

@interface ETSCourse (CoreDataGeneratedAccessors)

- (void)addEvaluationsObject:(ETSEvaluation *)value;
- (void)removeEvaluationsObject:(ETSEvaluation *)value;
- (void)addEvaluations:(NSSet *)values;
- (void)removeEvaluations:(NSSet *)values;

@end
