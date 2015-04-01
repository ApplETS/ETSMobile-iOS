//
//  ETSBandwidthViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-12-31.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSBandwidthViewController.h"
#import "ETSBandwidth.h"
#import "ETSBandwidthCell.h"
#import "ETSCoreDataHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface ETSBandwidthViewController () <UIPopoverControllerDelegate>
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSNumber *usedBandwidth;
@property (nonatomic, strong) NSNumber *limitBandwidth;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *phaseLabel;
@property (weak, nonatomic) IBOutlet UILabel *apartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *usageLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *usageProgressView;
@property (nonatomic, copy)   NSString *apartment;
@property (nonatomic, strong) NSString *phase;
@property (nonatomic, copy)   NSString *month;
@end

@implementation ETSBandwidthViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)updateBandwidthWithPhase:(NSString *)phase apartment:(NSString *)apartment
{
    
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    self.usageLabel.text = @" ";
    self.usageProgressView.progress = 0;
    self.dateLabel.text = @"Consommation :";
    
    if ([phase length] == 0 || [apartment length] == 0) {
        return;
    }
    
    self.synchronization.request = [NSURLRequest requestForBandwidthWithMonth:self.month residence:apartment phase:phase];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:apartment forKey:@"apartment"];
    [userDefaults setObject:phase forKey:@"phase"];
    
    self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", phase];
    self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", apartment];
    
    self.phase = phase;
    self.apartment = apartment;
    
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    self.month = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month]) stringValue];
    
    self.cellIdentifier = @"BandwidthIdentifier";
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"Bandwidth";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"query.results.table";
    synchronization.dateFormatter = self.dateFormatter;
    synchronization.predicate = [NSPredicate predicateWithFormat:@"month ==[c] %@", self.month];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.groupingSeparator = @" ";
    self.formatter.groupingSize = 3;
    self.formatter.usesGroupingSeparator = YES;
    self.formatter.maximumFractionDigits = 2;
    self.formatter.minimumFractionDigits = 2;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Bande passante";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    if ([self.apartment length] > 0 && [self.phase integerValue] > 0) {
        self.synchronization.request = [NSURLRequest requestForBandwidthWithMonth:self.month residence:self.apartment phase:self.phase];
        self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", self.phase];
        self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", self.apartment];
        self.phaseSegmentedControl.selectedSegmentIndex = [self.phase integerValue] - 1;
        self.apartmentTextField.text = self.apartment;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
        df.dateFormat = @"LLLL yyyy";
        self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
    } else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) self.tableView.tableHeaderView.hidden = YES;
        self.dataNeedRefresh = NO;
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [self.tableView addGestureRecognizer:tapGesture];
    }
}

-(void)hideKeyBoard {
    [self.apartmentTextField resignFirstResponder];
    
    NSString *phase = [@(self.phaseSegmentedControl.selectedSegmentIndex+1) stringValue];
    [self updateBandwidthWithPhase:phase apartment:self.apartmentTextField.text];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"port" ascending:YES]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"date" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (IBAction)phaseDidChange:(id)sender
{
    [self updateBandwidthWithPhase:[@(self.phaseSegmentedControl.selectedSegmentIndex+1) stringValue] apartment:self.apartmentTextField.text];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSBandwidth *bandwidth = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    NSDateFormatter *titleFormatter = [[NSDateFormatter alloc] init];
    titleFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    titleFormatter.dateFormat = @"cccc, d LLLL yyyy";
    return [titleFormatter stringFromDate:bandwidth.date];
}

- (void)configureCell:(ETSBandwidthCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSBandwidth *bandiwdth = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.portLabel.text = bandiwdth.port;
    cell.uploadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬆︎)", [self.formatter stringFromNumber:bandiwdth.upload]];
    cell.downloadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬇︎)", [self.formatter stringFromNumber:bandiwdth.download]];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) self.tableView.tableHeaderView.hidden = YES;
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    
    NSArray *tables = (NSArray *)objects;

    if ([tables count] < 2) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        self.tableView.tableHeaderView.hidden = YES;
        return nil;
    }
    
    NSArray *days = (tables[0])[@"tbody"][@"tr"];

    NSInteger i = 0;
    for (NSDictionary * day in days) {
        if (i++ == 0) continue;
        if ([day[@"td"] count] != 4) continue;
        
        NSString *date = day[@"td"][1];
        if ([date isEqualToString:@"Journée en cours"]) date = [self.dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.dateFormatter dateFromString:date]];
        
        entry[@"port"] = day[@"td"][0];
        entry[@"date"] = date;
        entry[@"upload"] = day[@"td"][2][@"content"];
        entry[@"download"] = day[@"td"][3][@"content"];
        entry[@"month"] = [@([components month]) stringValue];
        entry[@"id"] = [NSString stringWithFormat:@"%@-%@", day[@"td"][0], date];
        [entries addObject:entry];
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.decimalSeparator = @".";
    self.usedBandwidth = [f numberFromString:[days lastObject][@"td"][1][@"content"]];
    self.limitBandwidth = [f numberFromString:tables[1][@"tbody"][@"tr"][1][@"td"][1][@"content"]];

    NSNumber *used = @([self.usedBandwidth floatValue]/1024);
    NSNumber *limit = @([self.limitBandwidth floatValue]/1024);
    self.usageLabel.text = [NSString stringWithFormat:@"%@ Go sur %@ Go", [self.formatter stringFromNumber:used], [self.formatter stringFromNumber:limit]];
    self.usageProgressView.progress = [self.usedBandwidth floatValue] / [self.limitBandwidth floatValue];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    df.dateFormat = @"LLLL yyyy";
    self.dateLabel.text = [NSString stringWithFormat:@"Consommation, %@ :", [df stringFromDate:[NSDate date]]];
    
    self.tableView.tableHeaderView.hidden = NO;
    
    return entries;
}

@end
