//
//  ETSEvent.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-30.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSEvent : NSManagedObject

@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * id;

@end
