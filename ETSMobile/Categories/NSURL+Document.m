//
//  NSURL+Document.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "NSURL+Document.h"

@implementation NSURL (Document)

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
