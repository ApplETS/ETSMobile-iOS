//
//  ETSCoreDataHelper.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-11.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETSCoreDataHelper : NSObject

+ (void)deleteAllObjectsWithEntityName:(NSString *)entity inManagedObjectContext:(NSManagedObjectContext *)managedObject;

@end
