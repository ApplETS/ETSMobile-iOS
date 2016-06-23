//
//  NotificationHelper.h
//  ETSMobile
//
//  Created by Alyssa Bouchenak on 2016-06-23.
//  Copyright © 2016 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationHelper : NSObject {
    NSString *courseId;
}

@property (nonatomic, retain) NSString *courseId;

+ (id)sharedInstance;

@end
