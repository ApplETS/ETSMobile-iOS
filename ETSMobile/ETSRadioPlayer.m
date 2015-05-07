//
//  ETSRadioPlayer.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSRadioPlayer.h"
#import "ETSRadioViewController.h"
#import "ETSAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ETSRadioPlayer ()
@property (nonatomic, strong)   AVPlayer        *player;
@property (nonatomic, strong)   AVPlayerItem    *playerItem;
@property (nonatomic, copy)     NSString        *currentTitle;
@end

@implementation ETSRadioPlayer

+ (id)sharedInstance
{
    static ETSRadioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startRadio
{
    [[AVAudioSession sharedInstance] setActive:YES error: NULL];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL  URLWithString:@"http://radiopiranha.com:8000/radiopiranha.mp3"]];
    [self.playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];

    _player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [_player play];
}

- (void)stopRadio
{
    self.currentTitle = nil;
    [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
    [_player pause];
    _player = nil;
    
    [[AVAudioSession sharedInstance] setActive:NO error: NULL];
}

- (void)playOrPause
{
    if ([[ETSRadioPlayer sharedInstance] isPlaying]) {
        [[ETSRadioPlayer sharedInstance] stopRadio];
    } else {
        [[ETSRadioPlayer sharedInstance] startRadio];
    }
}

- (BOOL)isPlaying
{
    return self.player && self.player.rate;
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        AVPlayerItem* playerItem = object;
        for (AVMetadataItem* metadata in playerItem.timedMetadata)
            if ([metadata.commonKey isEqualToString:@"title"]) self.currentTitle = metadata.stringValue;
        
        id controller = ((ETSAppDelegate *)[[UIApplication sharedApplication] delegate]).dynamicsDrawerViewController.paneViewController;
        
        if ([controller isKindOfClass:[UINavigationController class]]) controller = ((UINavigationController *)controller).topViewController;
        
        if ([controller isKindOfClass:[ETSRadioViewController class]]) {
            ((ETSRadioViewController *)controller).navigationItem.prompt = self.currentTitle;
        }

        MPNowPlayingInfoCenter* info = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary* newInfo = [NSMutableDictionary dictionary];
        newInfo[MPMediaItemPropertyTitle] = self.currentTitle;
        info.nowPlayingInfo = newInfo;
    }
}

@end
