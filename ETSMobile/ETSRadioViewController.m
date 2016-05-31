//
//  ETSRadioViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-21.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSRadioViewController.h"
#import "ETSAppDelegate.h"
#import "ETSEvent.h"
#import "ETSRadioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NSURLRequest+API.h"
#import "MSCollectionViewCalendarLayout.h"

#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "ETSRadioCell.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"

#import <Crashlytics/Crashlytics.h>

NSString * const MSRadioEventCellReuseIdentifier = @"MSEventCellReuseIdentifier";
NSString * const MSRadioDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const MSRadioTimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";

@interface ETSRadioViewController () <MSCollectionViewDelegateCalendarLayout, NSFetchedResultsControllerDelegate, ETSSynchronizationDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;
@property (strong, nonatomic) ETSSynchronization *synchronization;
@property (nonatomic, strong) UIBarButtonItem *playBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *pauseBarButtonItem;
@end

@implementation ETSRadioViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playRadio:)];
    self.pauseBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseRadio:)];

    if ([[ETSRadioPlayer sharedInstance] isPlaying])
        self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
    else
        self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
    
    self.title = @"Radio Piranha";
    
    self.collectionViewCalendarLayout = (MSCollectionViewCalendarLayout *)self.collectionViewLayout;
    self.collectionViewCalendarLayout.delegate = self;
    self.collectionViewCalendarLayout.hourHeight = 40;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForRadio];
    synchronization.entityName = @"Event";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"data";
    synchronization.appletsServer = YES;
    synchronization.predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"source ==[c] %@", @"radiopiranha1"], [NSPredicate predicateWithFormat:@"source ==[c] %@", @"radiopiranha2"], [NSPredicate predicateWithFormat:@"source ==[c] %@", @"programmationradiopiranha"], [NSPredicate predicateWithFormat:@"source ==[c] %@", @"radiopiranhacom"]]];
    synchronization.dateFormatter = dateFormatter;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:ETSRadioCell.class forCellWithReuseIdentifier:MSRadioEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSRadioDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSRadioTimeRowHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSArray *channels = @[@"radiopiranha1", @"radiopiranha2", @"programmationradiopiranha", @"radiopiranhacom"];
    
    NSMutableArray *events = [NSMutableArray array];
    
    for (NSString *channel in channels) {
        
        if (!objects[channel]) continue;

        for (NSDictionary *e in objects[channel]) {
            NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:e];
            event[@"source"] = channel;
            [events addObject:event];
        }
    }
    return events;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[self.synchronization.predicate, [NSPredicate predicateWithFormat:@"start >= %@", [NSDate date]]]];
    
    fetchRequest.predicate = self.synchronization.predicate;
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"day" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Radio Piranha"
                        contentType:@"Radio"
                          contentId:@"ETS-Radio"
                   customAttributes:@{}];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([[ETSRadioPlayer sharedInstance] currentTitle]) {
        self.navigationItem.prompt = [[ETSRadioPlayer sharedInstance] currentTitle];
    } else {
        self.navigationItem.prompt = nil;
    }
    
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    MPRemoteCommand *pauseCommand = [commandCenter pauseCommand];
    [pauseCommand removeTarget:nil];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:self action:@selector(playOrPauseWithUIUpdate)];

    MPRemoteCommand *playCommand = [commandCenter playCommand];
    [playCommand removeTarget:nil];
    [playCommand setEnabled:YES];
    [playCommand addTarget:self action:@selector(playOrPauseWithUIUpdate)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Cette portion de code est un hack pour éviter le crash sous iOS 7 qui ne tolère pas d'utiliser les blocks.
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    MPRemoteCommand *pauseCommand = [commandCenter pauseCommand];
    [pauseCommand removeTarget:nil];
    [pauseCommand setEnabled:YES];
    [pauseCommand addTarget:[ETSRadioPlayer sharedInstance] action:@selector(playOrPause)];

    MPRemoteCommand *playCommand = [commandCenter playCommand];
    [playCommand removeTarget:nil];
    [playCommand setEnabled:YES];
    [playCommand addTarget:[ETSRadioPlayer sharedInstance] action:@selector(playOrPause)];

    [super viewDidDisappear:animated];
}

- (void)playOrPauseWithUIUpdate
{
    if ([[ETSRadioPlayer sharedInstance] isPlaying]) {
        [[ETSRadioPlayer sharedInstance] stopRadio];
        self.navigationItem.prompt = nil;
        self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
    } else {
        [[ETSRadioPlayer sharedInstance] startRadio];
        self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // On iPhone, adjust width of sections on interface rotation. No necessary in horizontal layout (iPad)
    if (self.collectionViewCalendarLayout.sectionLayoutType == MSSectionLayoutTypeVerticalTile) {
        [self.collectionViewCalendarLayout invalidateLayoutCache];
        // These are the only widths that are defined by default. There are more that factor into the overall width.
        self.collectionViewCalendarLayout.sectionWidth = (CGRectGetWidth(self.collectionView.frame) - self.collectionViewCalendarLayout.timeRowHeaderWidth - self.collectionViewCalendarLayout.contentMargin.right);
        [self.collectionView reloadData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [(id <NSFetchedResultsSectionInfo>)self.fetchedResultsController.sections[section] numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ETSRadioCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSRadioEventCellReuseIdentifier forIndexPath:indexPath];
    cell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSRadioDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        dayColumnHeader.day = day;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:day];
        NSDateComponents *components2 = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:currentDay];
        
        dayColumnHeader.currentDay = [[calendar dateFromComponents:components] isEqualToDate:[calendar dateFromComponents:components2]];
        view = dayColumnHeader;
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSRadioTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewCalendarLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    }
    return view;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionViewCalendarLayout invalidateLayoutCache];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

#pragma mark - MSCollectionViewCalendarLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = (self.fetchedResultsController.sections)[section];
    ETSEvent *event = [sectionInfo.objects firstObject];
    return event.day;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ETSEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.start;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ETSEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [event.end dateByAddingTimeInterval:-60*2];
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

- (IBAction)playRadio:(id)sender
{
    [[ETSRadioPlayer sharedInstance] startRadio];
    
    self.navigationItem.rightBarButtonItem = self.pauseBarButtonItem;
}

- (IBAction)pauseRadio:(id)sender
{
    [[ETSRadioPlayer sharedInstance] stopRadio];
    self.navigationItem.prompt = nil;
    
    self.navigationItem.rightBarButtonItem = self.playBarButtonItem;
}

@end
