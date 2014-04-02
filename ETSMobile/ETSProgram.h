//
//  ETSProgram.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-29.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSProgram : NSManagedObject

@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * start;
@property (nonatomic, retain) NSString * end;
@property (nonatomic, retain) NSNumber * results;
@property (nonatomic, retain) NSNumber * csucces;
@property (nonatomic, retain) NSNumber * cfailed;
@property (nonatomic, retain) NSNumber * cregistred;
@property (nonatomic, retain) NSNumber * ccompleted;
@property (nonatomic, retain) NSNumber * cpotential;
@property (nonatomic, retain) NSNumber * cresearch;
@property (nonatomic, retain) NSNumber * ccequivalence;

@end
