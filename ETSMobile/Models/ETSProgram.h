//
//  ETSProgram.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSProgram : NSManagedObject

@property (nonatomic, retain) NSNumber * ccequivalence;
@property (nonatomic, retain) NSNumber * ccompleted;
@property (nonatomic, retain) NSNumber * cfailed;
@property (nonatomic, retain) NSNumber * code;
@property (nonatomic, retain) NSNumber * cpotential;
@property (nonatomic, retain) NSNumber * cregistred;
@property (nonatomic, retain) NSNumber * cresearch;
@property (nonatomic, retain) NSNumber * csucces;
@property (nonatomic, retain) NSString * end;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * profile;
@property (nonatomic, retain) NSNumber * results;
@property (nonatomic, retain) NSString * start;
@property (nonatomic, retain) NSString * status;

@end
