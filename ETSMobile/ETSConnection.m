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

- (void)loadDataWithRequest:(NSURLRequest *)request entityName:(NSString *)entityName forObjectsKeyPath:(NSString *)objectsKeyPath compareKey:(NSString *)key
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    __weak typeof(self) bself = self;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!data) return;
        
        NSError *jsonError = nil;
        NSDictionary *jsonObjects = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        if ([[jsonObjects valueForKeyPath:@"d.erreur"] isEqualToString:@"Code d'accès ou mot de passe invalide"]) {
            [self.delegate connection:self didReveiveResponse:ETSConnectionResponseAuthenticationError];
            return;
        } else if ([[jsonObjects valueForKeyPath:@"d.erreur"] length] == 0) {
            [self.delegate connection:self didReveiveResponse:ETSConnectionResponseValid];
        } else {
            [self.delegate connection:self didReveiveResponse:ETSConnectionResponseUnknownError];
            return;
        }
        
        id json = [jsonObjects valueForKeyPath:objectsKeyPath];
        
        NSManagedObjectContext *managedObjectContext = [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        //NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
        
        NSDictionary *mappings = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ETSAPICoreDataMapping" ofType:@"plist"]];
        
        if ([json isKindOfClass:[NSArray class]])
        {
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:[mappings[entityName] valueForKey:key] ascending:YES];
            json = [((NSArray *)json) sortedArrayUsingDescriptors:@[descriptor]];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjectContext];
            [fetchRequest setEntity:entity];

            NSArray *sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:key ascending:YES]];
            [fetchRequest setSortDescriptors:sortDescriptors];
            
            NSError *fetchError;
            NSMutableArray *coredataArray = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSUInteger i;
            for (i = 0; i < [json count]; i++) {
                NSDictionary *lObject = json[i];
                NSManagedObject * rObject = nil;
                if (i < [coredataArray count]) rObject = coredataArray[i];
                
                NSString *lString = [lObject valueForKey:[mappings[entityName] valueForKey:key]];
                NSString *rString = [rObject valueForKey:key];
                
                if (!rObject || [lString caseInsensitiveCompare:rString] == NSOrderedAscending) {
                    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
                    [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[entityName]];
                    [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
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
                    [rObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[entityName]];
                    [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:rObject];
                }
            }
            
            while (i < [coredataArray count]) {
                NSDictionary *lObject = json[i];
                NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjectContext];
                [managedObject safeSetValuesForKeysWithDictionary:lObject dateFormatter:dateFormatter mapping:mappings[entityName]];
                [bself.delegate connection:bself didReceiveObject:lObject forManagedObject:managedObject];
                i++;
            }

            NSError *error;
            if (![managedObjectContext save:&error]) {
                // FIXME: Update to handle the error appropriately.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
        

        
    }];
}

@end

