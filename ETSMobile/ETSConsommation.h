//
//  ETSConsommation.h
//  ETSMobile
//
//  Created by Samuel Bellerose on 2016-04-11.
//  Copyright © 2016 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ETSConsommation : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * download;
@property (nonatomic, retain) NSNumber * upload;
@property (nonatomic, retain) NSString * idChambre;
@property (nonatomic, retain) NSString * id;

@end
