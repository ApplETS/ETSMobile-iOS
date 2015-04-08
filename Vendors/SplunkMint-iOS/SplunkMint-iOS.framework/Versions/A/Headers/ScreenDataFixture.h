//
//  ScreenDataFixture.h
//  Splunk-iOS
//
//  Created by G.Tas on 2/21/14.
//  Copyright (c) 2014 Splunk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPLJSONModel.h"
#import "DataFixture.h"

@interface ScreenDataFixture : DataFixture

@property (nonatomic, strong) NSDictionary *screen;
@property (nonatomic, strong) NSMutableDictionary<SPLOptional>* ExtraData;

@end
