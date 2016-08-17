//
//  NotificationHelper.m
//  ETSMobile
//
//  Created by Alyssa Bouchenak on 2016-06-23.
//  Copyright © 2016 ApplETS. All rights reserved.
//

#import "NotificationHelper.h"

@implementation NotificationHelper

@synthesize courseId;

#pragma mark Singleton Methods

+ (id)sharedInstance{
    static NotificationHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        courseId = nil;
    }
    return self;
}

- (void)dealloc {
    
}

@end
