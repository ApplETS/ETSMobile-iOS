//
//  ETSBandwidth.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-03-16.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSBandwidth : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * download;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * month;
@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSNumber * upload;

@end
