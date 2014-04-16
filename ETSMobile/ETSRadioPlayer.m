//
//  ETSRadioPlayer.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSRadioPlayer.h"
#import "ETSRadioViewController.h"
#import "MFSideMenu.h"
#import "ETSAppDelegate.h"

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

- (BOOL)isPlaying
{
    return self.player && self.player.rate;
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        AVPlayerItem* playerItem = object;
        for (AVMetadataItem* metadata in playerItem.timedMetadata)
            if ([metadata.commonKey isEqualToString:@"title"]) self.currentTitle = metadata.stringValue;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            UIViewController *controller = ((UINavigationController*)((MFSideMenuContainerViewController*)[(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController).centerViewController).visibleViewController;
            if ([controller isKindOfClass:[ETSRadioViewController class]]) {
                controller.navigationItem.prompt = self.currentTitle;
            }
        }
        else {
            UITabBarController *tbc =  (UITabBarController *)[(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] window].rootViewController;
            
            id svc = tbc.selectedViewController;
            
            if ([svc isKindOfClass:[UINavigationController class]] && [((UINavigationController *)svc).topViewController isKindOfClass:[ETSRadioViewController class]]) {
                ((UINavigationController *)svc).topViewController.navigationItem.prompt = self.currentTitle;
            }
        }
    }
}

@end
