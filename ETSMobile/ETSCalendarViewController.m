//
//  ETSCalendarViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-24.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCalendarViewController.h"
#import "NSURLRequest+API.h"
#import "MSCollectionViewCalendarLayout.h"

#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSEventCell.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"

#import "ETSCalendar.h"
#import "ETSSession.h"

#import "ETSAuthenticationViewController.h"
#import "ETSMenuViewController.h"
#import "ETSUniversityCalendarViewController.h"

NSString * const MSEventCellReuseIdentifier = @"MSEventCellReuseIdentifier";
NSString * const MSDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const MSTimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";

@interface ETSCalendarViewController () <MSCollectionViewDelegateCalendarLayout, NSFetchedResultsControllerDelegate, ETSSynchronizationDelegate, ETSAuthenticationViewControllerDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;
@property (strong, nonatomic) ETSSynchronization *synchronizationSession;
@property (strong, nonatomic) NSDictionary *synchronizations;
@end

@implementation ETSCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    #ifdef __USE_TESTFLIGHT
    [TestFlight passCheckpoint:@"CALENDAR_VIEWCONTROLLER"];
    #endif
    
    self.title = NSLocalizedString(@"Horaire", nil);
    
    self.collectionViewCalendarLayout = (MSCollectionViewCalendarLayout *)self.collectionViewLayout;
    self.collectionViewCalendarLayout.delegate = self;
    self.collectionViewCalendarLayout.hourHeight = 40;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    NSDateFormatter *sessionFormatter = [NSDateFormatter new];
    sessionFormatter.dateFormat = @"yyyy-MM-dd";
    ETSSynchronization *synchronizationSession = [[ETSSynchronization alloc] init];
    synchronizationSession.request = [NSURLRequest requestForSession];
    synchronizationSession.entityName = @"Session";
    synchronizationSession.compareKey = @"acronym";
    synchronizationSession.objectsKeyPath = @"d.liste";
    synchronizationSession.sortSelector = @selector(localizedCaseInsensitiveCompare:);
    synchronizationSession.dateFormatter = sessionFormatter;
    self.synchronizationSession = synchronizationSession;
    self.synchronizationSession.delegate = self;

    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:MSEventCell.class forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Calendar"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    NSDate *today = [calendar dateFromComponents:components];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"start >= %@", today];
    
    // Divide into sections by the "day" key path
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"day" cacheName:nil];
    self.fetchedResultsController.delegate = self;
    [self.fetchedResultsController performFetch:nil];
    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            ac.delegate = self;
            [self.navigationController pushViewController:ac animated:NO];
        } else {
            UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
            authenticationController.delegate = self;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController presentViewController:navigationController animated:NO completion:nil];
        }
    }
}

- (NSArray *)activeSessions
{
    NSMutableArray *sessions = [NSMutableArray array];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    NSDate *now = [NSDate date];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"end >= %@", now];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    fetchRequest.returnsDistinctResults = YES;
    fetchRequest.propertiesToFetch = @[@"acronym"];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (ETSSession *session in results) {
        [sessions addObject:session.acronym];
    }
    return sessions;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ETSUniversityCalendarViewController *controller = [segue destinationViewController];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) controller.preferredContentSize = CGSizeMake(400, 600);
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
    NSDate *now = [NSDate date];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"end >= %@", now];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES]];
    fetchRequest.returnsDistinctResults = YES;
    
    NSDate *min = nil;
    NSDate *max = nil;
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (ETSSession *session in results) {
        if (!min || session.start < min) min = session.start;
        if (!max || session.end > max) max = session.end;
    }
    
    controller.start = min;
    controller.end = max;
    controller.managedObjectContext = self.managedObjectContext;
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    if (synchronization != self.synchronizationSession) return;
    
    NSArray *sessions = [self activeSessions];
    
    NSMutableDictionary *synchronizations = [NSMutableDictionary dictionary];
    
    for (NSString *session in sessions) {
        ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
        synchronization.request = [NSURLRequest requestForCalendar:session];
        synchronization.entityName = @"Calendar";
        synchronization.compareKey = @"id";
        synchronization.objectsKeyPath = @"d.ListeDesSeances";
        synchronization.dateFormatter = self.dateFormatter;
        synchronization.delegate = self;
        synchronization.predicate = [NSPredicate predicateWithFormat:@"session ==[c] %@", session];
        
        synchronizations[session] = synchronization;
        [synchronization synchronize:nil];
    }
    self.synchronizations = synchronizations;
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{
    
    if (response == ETSSynchronizationResponseAuthenticationError) {
        
        if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]] || self.presentedViewController) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d'accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        }
        else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                ac.delegate = self;
                [self.navigationController pushViewController:ac animated:YES];
            } else {
                UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
                authenticationController.delegate = self;
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            }
        }
    }
    else if (response == ETSSynchronizationResponseValid) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if ([[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.synchronizationSession.request = [NSURLRequest requestForSession];
    [self.synchronizationSession synchronize:nil];
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return [ETSAuthenticationViewController validateJSONResponse:response];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.synchronizationSession synchronize:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
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
    MSEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSEventCellReuseIdentifier forIndexPath:indexPath];
    cell.event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        dayColumnHeader.day = day;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:day];
        NSDateComponents *components2 = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:currentDay];
        
        dayColumnHeader.currentDay = [[calendar dateFromComponents:components] isEqualToDate:[calendar dateFromComponents:components2]];
        view = dayColumnHeader;
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
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
    ETSCalendar *event = [sectionInfo.objects firstObject];
    return event.day;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ETSCalendar *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.start;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ETSCalendar *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return event.end;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

- (NSString *)dateStringFromAPIString:(NSString *)dateString
{
    NSString *cleaned = [[dateString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSTimeInterval subdate = [[cleaned substringToIndex:cleaned.length - 3] doubleValue];
    return [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:subdate]];
}


- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (synchronization == self.synchronizationSession) return objects;
    
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:[objects count]];
    NSArray* arrayOfKeys = [self.synchronizations allKeysForObject:synchronization];
    if ([arrayOfKeys count] == 0) return nil;
    
    for (NSDictionary *object in objects) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:object];
        
        event[@"dateDebut"] = [self dateStringFromAPIString:object[@"dateDebut"]];
        event[@"dateFin"]   = [self dateStringFromAPIString:object[@"dateFin"]];
        event[@"id"]        = [NSString stringWithFormat:@"%@%@%@", event[@"dateDebut"], event[@"dateFin"], event[@"coursGroupe"]];
        event[@"session"]   = arrayOfKeys[0];
        
        [events addObject:event];
    }
    return events;
}

@end
