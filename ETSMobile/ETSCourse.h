//
//  ETSCourse.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-27.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

#import "ETSDictionaryConvertible.h"

@class ETSEvaluation;

#if TARGET_WATCH_EXTENSION
@interface ETSCourse : NSObject<ETSDictionaryConvertible>
#else
@interface ETSCourse : NSManagedObject<ETSDictionaryConvertible>
#endif

@property (nonatomic, retain) NSString *_Nonnull acronym;
@property (nonatomic, retain) NSString *_Nonnull credits;
@property (nonatomic, retain) NSString *_Nullable grade;
@property (nonatomic, retain) NSString *_Nonnull group;
@property (nonatomic, retain) NSString *_Nonnull id;
@property (nonatomic, retain) NSNumber *_Nullable mean;
@property (nonatomic, retain) NSNumber *_Nullable median;
@property (nonatomic, retain) NSString *_Nullable order;
@property (nonatomic, retain) NSNumber *_Nullable percentile;
@property (nonatomic, retain) NSString *_Nonnull program;
@property (nonatomic, retain) NSNumber *_Nullable results;
@property (nonatomic, retain) NSNumber *_Nonnull season;
@property (nonatomic, retain) NSString *_Nonnull session;
@property (nonatomic, retain) NSNumber *_Nullable std;
@property (nonatomic, retain) NSString *_Nonnull title;
@property (nonatomic, retain) NSNumber *_Nonnull year;
@property (nonatomic, retain) NSNumber *_Nullable resultOn100;
@property (nonatomic, retain) NSSet<ETSEvaluation *> *_Nullable evaluations;

- (NSNumber *_Nonnull)totalEvaluationWeighting;

@end

@interface ETSCourse (CoreDataGeneratedAccessors)

- (void)addEvaluationsObject:(ETSEvaluation *)value;
- (void)removeEvaluationsObject:(ETSEvaluation *)value;
- (void)addEvaluations:(NSSet *)values;
- (void)removeEvaluations:(NSSet *)values;

@end
