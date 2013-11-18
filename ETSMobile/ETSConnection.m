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

@end

@implementation ETSConnection

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

        if ([self.delegate respondsToSelector:@selector(connection:didReceiveDictionary:)]) [self.delegate connection:self didReceiveDictionary:jsonObjects];

        id apiError = [jsonObjects valueForKeyPath:@"d.erreur"];
        
        if ([apiError isKindOfClass:[NSString class]] && [apiError isEqualToString:@"Code d'accès ou mot de passe invalide"]) {
            if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) [self.delegate connection:self didReveiveResponse:ETSConnectionResponseAuthenticationError];
            return;
        } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] == 0) {
            if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) [self.delegate connection:self didReveiveResponse:ETSConnectionResponseValid];
        } else if ([apiError isKindOfClass:[NSString class]] && [apiError length] > 0) {
            if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) [self.delegate connection:self didReveiveResponse:ETSConnectionResponseUnknownError];
            return;
        }
        
        id json = [jsonObjects valueForKeyPath:self.objectsKeyPath];
        
        NSManagedObjectContext *managedObjectContext = [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NSDictionary *mappings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ETSAPICoreDataMapping" ofType:@"plist"]];
        
        if ([json isKindOfClass:[NSArray class]])
        {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:[mappings[self.entityName] valueForKey:self.compareKey] ascending:YES];
            json = [((NSArray *)json) sortedArrayUsingDescriptors:@[descriptor]];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];

            if (self.predicate) [fetchRequest setPredicate:self.predicate];
            
            NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:self.compareKey ascending:YES]];
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSError *fetchError;
            NSMutableArray *coredataArray = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSUInteger i;
            for (i = 0; i < [json count]; i++) {
                NSDictionary *lObject = json[i];
                NSManagedObject * rObject = nil;
                if (i < [coredataArray count]) rObject = coredataArray[i];
                
                id l = [lObject valueForKey:[mappings[self.entityName] valueForKey:self.compareKey]];
                NSString *lString = nil;
                if ([l isKindOfClass:[NSNumber class]]) lString = [l stringValue];
                else if ([l isKindOfClass:[NSString class]]) lString  = l;
                
                NSString *rString = [lObject valueForKey:self.compareKey];
                

                if (!rObject || [lString caseInsensitiveCompare:rString] == NSOrderedAscending) {
                    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
                    [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[self.entityName]];
                    if ([self.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)]) [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
                }
                
                else if ([lString caseInsensitiveCompare:rString] == NSOrderedDescending) {
                    [managedObjectContext deleteObject:rObject];
                    [coredataArray removeObject:rObject];
                    i--;
                    continue;
                }
                
                else if ([lString caseInsensitiveCompare:rString] == NSOrderedSame) {
                    NSDictionary *attributes = [[rObject entity] attributesByName];
                    for (NSString *attribute in attributes) {
                        [rObject setValue:nil forKey:attribute];
                    }
                    [rObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[self.entityName]];
                    if ([self.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)])
                    [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:rObject];
                }
            }
            
            while (i < [coredataArray count]) {
                NSDictionary *lObject = json[i];
                NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:managedObjectContext];
                [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[self.entityName]];
                if ([self.delegate respondsToSelector:@selector(connection:didReceiveObject:forManagedObject:)])
                [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
                i++;
            }

            NSError *error;
            if (![managedObjectContext save:&error]) {
                // FIXME: Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        [self.delegate connectionDidFinishLoading:self];
        
    }];
}

@end

