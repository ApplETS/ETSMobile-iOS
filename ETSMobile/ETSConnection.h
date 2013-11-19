//
//  ETSViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-17.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ETSConnectionResponse) {
    ETSConnectionResponseAuthenticationError,
    ETSConnectionResponseUnknownError,
    ETSConnectionResponseValid
};

@protocol ETSConnectionDelegate;

@interface ETSConnection : NSObject

- (void)loadData;
- (void)saveManagedObjectContext;

@property (nonatomic, weak)   id<ETSConnectionDelegate> delegate;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, copy)   NSString *entityName;
@property (nonatomic, copy)   NSString *objectsKeyPath;
@property (nonatomic, copy)   NSString *compareKey;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSArray *ignoredAttributesFromUpdate;
@property (nonatomic, assign) BOOL saveAutomatically;

@end

@protocol ETSConnectionDelegate<NSObject>
@optional
- (void)connection:(ETSConnection *)connection didReceiveDictionary:(NSDictionary *)dictionary;
- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject;
- (void)connection:(ETSConnection *)connection didReceiveResponse:(ETSConnectionResponse)response;
- (void)connectionDidFinishLoading:(ETSConnection *)connection;
@end