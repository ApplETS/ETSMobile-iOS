//
//  ETSCoreDataHelper.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-11.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCoreDataHelper.h"

@implementation ETSCoreDataHelper

+ (void)deleteAllObjectsWithEntityName:(NSString *)entity inManagedObjectContext:(NSManagedObjectContext *)managedObject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:managedObject]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [managedObject executeFetchRequest:fetchRequest error:&error];

    for (NSManagedObject *object in objects) {
        [managedObject deleteObject:object];
    }
    
    NSError *saveError = nil;
    [managedObject save:&saveError];
}

@end
