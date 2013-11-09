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

- (void)loadDataWithRequest:(NSURLRequest *)request entityName:(NSString *)entityName forObjectsKeyPath:(NSString *)objectsKeyPath compareKey:(NSString *)key;

@property (nonatomic, weak)   id<ETSConnectionDelegate> delegate;

@end

@protocol ETSConnectionDelegate
- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject;
- (void)connection:(ETSConnection *)connection didReveiveResponse:(ETSConnectionResponse)response;
@end