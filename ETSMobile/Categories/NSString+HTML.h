//
//  NSString+HTML.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-17.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)stringByStrippingHTML;
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end
