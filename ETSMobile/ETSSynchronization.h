//
//  ETSSynchronization.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-21.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ETSSynchronizationResponse) {
    ETSSynchronizationResponseAuthenticationError,
    ETSSynchronizationResponseUnknownError,
    ETSSynchronizationResponseValid
};

@protocol ETSSynchronizationDelegate;

@interface ETSSynchronization : NSObject

- (BOOL)synchronize:(NSError * __autoreleasing *)error;
- (void)saveManagedObjectContext;

@property (nonatomic, weak) id<ETSSynchronizationDelegate> delegate;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy)   NSString *entityName;
@property (nonatomic, copy)   NSString *objectsKeyPath;
@property (nonatomic, copy)   NSString *compareKey;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *ignoredAttributes;
@property (nonatomic, assign) SEL sortSelector;
@property (nonatomic, assign) BOOL saveAutomatically;

@end


@protocol ETSSynchronizationDelegate<NSObject>
@optional
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveDictionary:(NSDictionary *)dictionary;
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject;
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response;
- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization;
- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects;
- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response;
@end