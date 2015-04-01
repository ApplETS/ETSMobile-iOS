//
//  ETSEvent.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSEvent : NSManagedObject

@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * title;

- (NSDate *)day;

@end
