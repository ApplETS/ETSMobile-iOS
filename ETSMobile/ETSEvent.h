//
//  ETSEvent.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-05.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSEvent : NSManagedObject

@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * source;

- (NSDate *)day;

@end
