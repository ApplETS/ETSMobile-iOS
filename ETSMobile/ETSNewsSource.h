//
//  ETSNewsSource.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-20.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSNewsSource : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * group;
@property (nonatomic, retain) NSNumber * enabled;

@end
