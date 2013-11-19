//
//  ETSProfile.h
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSProfile : NSManagedObject
    @property (nonatomic, retain) NSString * firstName;
    @property (nonatomic, retain) NSString * lastName;
    @property (nonatomic, retain) NSString * permanentCode;
    @property (nonatomic, retain) NSDecimalNumber * balance;
    @property (nonatomic, retain) NSString * program;
    @property (nonatomic) int creditsPassed;
    @property (nonatomic) int creditsFailed;
    @property (nonatomic) int creditsSubscribed;
    @property (nonatomic, retain) NSDecimalNumber * gradeAverage;
@end