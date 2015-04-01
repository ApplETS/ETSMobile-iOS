//
//  ETSContact.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSContact : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * ext;
@property (nonatomic, retain) NSString * firstInitial;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * fullName;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * job;
@property (nonatomic, retain) NSString * lastInitial;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * office;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * service;

@end
