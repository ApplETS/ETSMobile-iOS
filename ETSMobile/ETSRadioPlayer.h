//
//  ETSRadioPlayer.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ETSRadioPlayer : NSObject

+ (id)sharedInstance;

- (void)stopRadio;
- (void)startRadio;
- (BOOL)isPlaying;
- (void)playOrPause;

@property (nonatomic, copy, readonly) NSString *currentTitle;

@end
