//
//  ETSRadioViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSRadioViewController.h"
#import "ETSAppDelegate.h"
#import "MFSideMenu.h"
#import <AVFoundation/AVFoundation.h>

@interface ETSRadioViewController ()
- (AVPlayer *)radioPlayer;
@property (nonatomic, strong) UIBarButtonItem *playBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *pauseBarButtonItem;
@end

@implementation ETSRadioViewController

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (AVPlayer *)radioPlayer
{
    return [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] radioPlayer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];

    
    self.playBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playRadio:)];
    self.pauseBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseRadio:)];

    if ([self radioPlayer] && [[self radioPlayer] rate])
        self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
    else
        self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
    
    self.title = @"Radio Piranha";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([[self.navigationController viewControllers] count] > 1)
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    else
        self.menuContainerViewController.panMode = MFSideMenuPanModeCenterViewController | MFSideMenuPanModeSideMenu;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.textLabel.text = @"L'horaire sera ici…";
    
    return cell;
}

- (IBAction)playRadio:(id)sender
{
    [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] startRadio];
    
    self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
}

- (IBAction)pauseRadio:(id)sender
{
    [(ETSAppDelegate *)[[UIApplication sharedApplication] delegate] stopRadio];
    
    self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
}

@end
