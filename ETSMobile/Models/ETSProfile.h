//
//  ETSProfile.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSProfile : NSManagedObject

@property (nonatomic, retain) NSNumber * balance;
@property (nonatomic, retain) NSNumber * creditsFailed;
@property (nonatomic, retain) NSNumber * creditsPassed;
@property (nonatomic, retain) NSNumber * creditsSubscribed;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * gradeAverage;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * permanentCode;
@property (nonatomic, retain) NSString * program;

@end
