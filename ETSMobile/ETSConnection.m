//
//  ETSViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-17.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSConnection.h"
#import "NSManagedObject+SetValues.h"
#import "ETSAppDelegate.h"

@interface ETSConnection ()
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
+ (NSManagedObjectContext *)mainManagedObjectContext;
@end

@implementation ETSConnection

- (id)init
{
    self = [super init];
    if (self) {
        self.saveAutomatically = YES;
        self.managedObjectContext = nil;
        self.ignoredAttributesFromUpdate = nil;
    }
    return self;
}

+ (NSManagedObjectContext *)mainManagedObjectContext
{
    return [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak typeof(self) bself = self;
    [NSURLConnection sendAsynchronousRequest:self.request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         //NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
         
         if (!data) return;
         
         NSError *jsonError = nil;
         NSDictionary *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
         
         if ([bself.delegate respondsToSelector:@selector(connection:didReceiveDictionary:)]) [bself.delegate connection:bself didReceiveDictionary:jsonObjects];
         
         id apiError = [jsonObjects valueForKeyPath:@"d.erreur"];
         
         if ([apiError isKindOfClass:[NSString class]] && [apiError isEqualToString:@"Code d'accès ou mot de passe invalide"]) {
             if ([bself.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) [bself.delegate connection:bself didReceiveResponse:ETSConnectionResponseAuthenticationError];
             if ([bself.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
                 [bself.delegate connectionDidFinishLoading:bself];
             return;
         } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] == 0) {
             if ([bself.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
                 [bself.delegate connection:bself didReceiveResponse:ETSConnectionResponseValid];
             }
         } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] > 0) {
             if ([bself.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) [bself.delegate connection:bself didReceiveResponse:ETSConnectionResponseUnknownError];
             if ([bself.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
                 [bself.delegate connectionDidFinishLoading:bself];
             return;
         }
         
         id json = [jsonObjects valueForKeyPath:bself.objectsKeyPath];
         
         if (bself.saveAutomatically)
             bself.managedObjectContext = [ETSConnection mainManagedObjectContext];
         else {
             bself.managedObjectContext = [[NSManagedObjectContext alloc] init];
             [bself.managedObjectContext setUndoManager:nil];
             [bself.managedObjectContext setPersistentStoreCoordinator:[[ETSConnection mainManagedObjectContext] persistentStoreCoordinator]];
             [[NSNotificationCenter defaultCenter] addObserver:bself selector:@selector(addControllerContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:bself.managedObjectContext];
         }
         
         NSDictionary *mappings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ETSAPICoreDataMapping" ofType:@"plist"]];
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         
         if ([json isKindOfClass:[NSArray class]])
         {
             NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:[mappings[bself.entityName] valueForKey:bself.compareKey] ascending:YES];
             json = [((NSArray *)json) sortedArrayUsingDescriptors:@[descriptor]];
             
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             NSEntityDescription *entity = [NSEntityDescription entityForName:bself.entityName inManagedObjectContext:bself.managedObjectContext];
             [fetchRequest setEntity:entity];
             
             if (bself.predicate) [fetchRequest setPredicate:bself.predicate];
             
             NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:bself.compareKey ascending:YES]];
             [fetchRequest setSortDescriptors:sortDescriptors];
             
             NSError *fetchError;
             NSMutableArray *coredataArray = [NSMutableArray arrayWithArray:[bself.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]];
             

             
             NSUInteger i;
             for (i = 0; i < [json count]; i++) {
                 
                 NSDictionary *lObject = json[i];
                 NSManagedObject * rObject = nil;
                 if (i < [coredataArray count]) rObject = coredataArray[i];
                 
                 id leftOperand = [lObject valueForKey:[mappings[bself.entityName] valueForKey:bself.compareKey]];
                 id rightOperand = [rObject valueForKey:bself.compareKey];
                 
                 NSComparisonResult comparisonResult;
                 if ([rightOperand isKindOfClass:[NSNumber class]]) {
                     comparisonResult = [leftOperand compare:rightOperand];
                 }
                 else if ([rightOperand isKindOfClass:[NSString class]]) {
                     comparisonResult = [leftOperand caseInsensitiveCompare:rightOperand];
                 }
                 
                 
                 if (!rObject || comparisonResult == NSOrderedAscending) {
                     NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:bself.entityName inManagedObjectContext:bself.managedObjectContext];
                     [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[bself.entityName]];
                     if ([bself.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)]) [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
                 }
                 
                 else if (comparisonResult == NSOrderedDescending) {
                     [bself.managedObjectContext deleteObject:rObject];
                     [coredataArray removeObject:rObject];
                     i--;
                     continue;
                 }
                 
                 else if (comparisonResult == NSOrderedSame) {
                     NSDictionary *attributes = [[rObject entity] attributesByName];
                     for (NSString *attribute in attributes) {
                         if ([bself.ignoredAttributesFromUpdate count] > 0 &&
                             [[bself.ignoredAttributesFromUpdate filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", attribute]] count] > 0) {
                             continue;
                         }
                         [rObject setValue:nil forKey:attribute];
                     }
                     [rObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[bself.entityName]];
                     if ([bself.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)])
                         [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:rObject];
                 }
             }
             
             while (i < [coredataArray count]) {
                 NSDictionary *lObject = json[i];
                 NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:bself.entityName inManagedObjectContext:bself.managedObjectContext];
                 [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[bself.entityName]];
                 if ([bself.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)])
                     [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
                 i++;
             }
         }
         else if ([json isKindOfClass:[NSDictionary class]]) {
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             NSEntityDescription *entity = [NSEntityDescription entityForName:bself.entityName inManagedObjectContext:bself.managedObjectContext];
             [fetchRequest setEntity:entity];
             
             if (bself.predicate) [fetchRequest setPredicate:bself.predicate];
             
             NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:bself.compareKey ascending:YES]];
             [fetchRequest setSortDescriptors:sortDescriptors];
             
             NSError *fetchError;
             NSArray *coredataArray = [bself.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
             
             if ([coredataArray count] > 0) {
                 NSManagedObject *coreObject = coredataArray[0];
                 NSDictionary *attributes = [[coreObject entity] attributesByName];
                 for (NSString *attribute in attributes) {
                     if ([bself.ignoredAttributesFromUpdate count] > 0 &&
                         [[bself.ignoredAttributesFromUpdate filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", attribute]] count] > 0) {
                         continue;
                     }
                     [coreObject setValue:nil forKey:attribute];
                 }
                 [coreObject safeSetValuesForKeysWithDictionary:json dateFormatter:dateFormatter mapping:mappings[bself.entityName]];
                 if ([bself.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)])
                     [bself.delegate connection:bself didReceiveObject:json forManagedObject:coreObject];
                 
             }
             
             else {
                 NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:bself.entityName inManagedObjectContext:bself.managedObjectContext];
                 [managedObject safeSetValuesForKeysWithDictionary:json dateFormatter:dateFormatter mapping:mappings[bself.entityName]];
                 if ([bself.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)]) [bself.delegate connection:bself didReceiveObject:json forManagedObject:managedObject];
             }
         }
         if (bself.saveAutomatically) {
             NSError *error;
             if (![bself.managedObjectContext save:&error]) {
                 // FIXME: Update to handle the error appropriately.
                 NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
             }
         }
         if ([bself.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
             [bself.delegate connectionDidFinishLoading:bself];
         
     }];
}

- (void)addControllerContextDidSave:(NSNotification*)saveNotification
{
	[[ETSConnection mainManagedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
}

- (void)saveManagedObjectContext
{
    if (self.managedObjectContext) {
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            // FIXME: Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
        self.managedObjectContext = nil;
    }
}

@end

