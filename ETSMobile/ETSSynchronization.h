//
//  ETSSynchronization.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-21.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const ETSSynchronizationErrorDomain;

typedef NS_ENUM(NSInteger, ETSSynchronizationErrorCode) {
    ETSSynchronizationErrorCodeNoData = 0,
};

typedef NS_ENUM(NSInteger, ETSSynchronizationResponse) {
    ETSSynchronizationResponseAuthenticationError,
    ETSSynchronizationResponseUnknownError,
    ETSSynchronizationResponseValid
};

@protocol ETSSynchronizationDelegate;

@interface ETSSynchronization : NSObject <NSURLSessionDataDelegate>

- (BOOL)synchronize:(void (^)(NSError *error))callback;
- (BOOL)synchronizeJSONArray:(NSArray *)jsonObjects error:(NSError * __autoreleasing *)error;
- (BOOL)synchronizeJSONDictionary:(NSDictionary *)jsonDictionary error:(NSError * __autoreleasing *)error;

- (void)saveManagedObjectContext;

@property (nonatomic, weak) id<ETSSynchronizationDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy)   NSString *entityName;
@property (nonatomic, copy)   NSString *objectsKeyPath;
@property (nonatomic, copy)   NSString *compareKey;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSArray *ignoredAttributes;
@property (nonatomic, assign) SEL sortSelector;
@property (nonatomic, assign) BOOL saveAutomatically;
@property (nonatomic, assign) BOOL appletsServer;

@end


@protocol ETSSynchronizationDelegate<NSObject>
@optional
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveDictionary:(NSDictionary *)dictionary;
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject;
- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response;
- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization withResponse:(NSURLResponse*)response error:(NSError*)error;
- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects;
- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response;
@end