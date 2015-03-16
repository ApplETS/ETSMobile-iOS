//
//  ETSNews.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-08-19.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSNews : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSDate * updatedDate;
@property (nonatomic, retain) NSString * ymdDate;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * thumbnailURL;


@end
