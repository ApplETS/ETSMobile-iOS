//
//  ETSCalendar.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSCalendar : NSManagedObject

@property (nonatomic, retain) NSString * course;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * room;
@property (nonatomic, retain) NSString * session;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;

@end
