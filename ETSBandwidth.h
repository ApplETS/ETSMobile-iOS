//
//  ETSBandwidth.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-10.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSBandwidth : NSManagedObject

@property (nonatomic, retain) NSString * port;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSNumber * upload;
@property (nonatomic, retain) NSNumber * download;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * month;

@end
