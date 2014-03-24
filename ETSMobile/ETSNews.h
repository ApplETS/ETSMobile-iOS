//
//  ETSNews.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-21.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSNews : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSDate * published;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;

@end
