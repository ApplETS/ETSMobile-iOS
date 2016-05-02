//
//  ETSSponsors.h
//  ETSMobile
//
//  Created by Alyssa Bouchenak on 2016-05-02.
//  Copyright © 2016 ApplETS. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ETSSponsors : NSManagedObject

@property (nonatomic, retain) NSString * image_url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;

@end
