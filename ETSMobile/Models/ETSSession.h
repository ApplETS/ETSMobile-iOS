//
//  ETSSession.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSSession : NSManagedObject

@property (nonatomic, retain) NSString * acronym;
@property (nonatomic, retain) NSDate * end;
@property (nonatomic, retain) NSDate * start;

@end
