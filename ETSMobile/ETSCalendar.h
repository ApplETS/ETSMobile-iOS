//
//  ETSCalendar.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-31.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSCalendar : NSManagedObject

@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * session;

- (NSDate *)day;
- (NSDictionary *)toDictionary;

@end
