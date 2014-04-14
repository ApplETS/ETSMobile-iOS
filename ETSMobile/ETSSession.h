//
//  ETSSession.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSSession : NSManagedObject

@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * end;

@end
