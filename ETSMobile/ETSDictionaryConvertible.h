//
//  ETSDictionaryConvertible.h
//  ETSMobile
//
//  Created by Charles Levesque on 2017-04-28.
//  Copyright © 2017 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@protocol ETSDictionaryConvertible <NSObject>

@required - (instancetype _Nonnull)initWithDictionary:(NSDictionary<NSString *, id> *_Nonnull)dictionary;
@required - (NSDictionary<NSString *, id> *_Nonnull)dictionary;
@required - (NSArray<NSString *> *_Nonnull)propertyList;

@end
