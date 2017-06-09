//
//  ETSEvaluation.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-11.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <objc/runtime.h>

#import "ETSDictionaryConvertible.h"

@class ETSCourse;

#if TARGET_WATCH_EXTENSION
@interface ETSEvaluation : NSObject<ETSDictionaryConvertible>
#else
@interface ETSEvaluation : NSManagedObject<ETSDictionaryConvertible>
#endif

@property (nonatomic, retain) NSDate *_Nullable date;
@property (nonatomic, retain) NSNumber *_Nullable mean;
@property (nonatomic, retain) NSNumber *_Nullable median;
@property (nonatomic, retain) NSString *_Nonnull name;
@property (nonatomic, retain) NSNumber *_Nullable percentile;
@property (nonatomic, retain) NSNumber *_Nullable result;
@property (nonatomic, retain) NSNumber *_Nullable std;
@property (nonatomic, retain) NSString *_Nullable team;
@property (nonatomic, retain) NSNumber *_Nullable total;
@property (nonatomic, retain) NSNumber *_Nullable weighting;
@property (nonatomic, retain) NSNumber *_Nonnull ignored;
@property (nonatomic, retain) ETSCourse *_Nonnull course;

@end
