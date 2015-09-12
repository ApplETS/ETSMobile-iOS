//
//  ETSBandwidthViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-12-31.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSBandwidthDetailViewController.h"
#import "ETSBandwidth.h"
#import "ETSBandwidthCell.h"
#import "ETSCoreDataHelper.h"

@interface ETSBandwidthDetailViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *apartment;
@property (nonatomic, copy) NSString *phase;
@property (nonatomic, copy) NSString *month;
@end

@implementation ETSBandwidthDetailViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)updateBandwidth:(id)sender
{
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    
    if ([self.phase length] == 0 || [self.apartment length] == 0) {
        return;
    }
    
    self.synchronization.request = [NSURLRequest requestForBandwidthWithMonth:self.month residence:self.apartment phase:self.phase];
    
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
    
    [self.refreshControl addTarget:self action:@selector(updateBandwidth:) forControlEvents:UIControlEventValueChanged];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    if ([self.apartment length] == 0 || [self.phase integerValue] == 0) {
        self.dataNeedRefresh = NO;
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    }
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
    ETSBandwidth *bandwidth = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.portLabel.text = bandwidth.port;
    cell.uploadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬆︎)", [self.formatter stringFromNumber:bandwidth.upload]];
    cell.downloadLabel.text = [NSString stringWithFormat:@"%@ Mo (⬇︎)", [self.formatter stringFromNumber:bandwidth.download]];
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    
    NSArray *tables = (NSArray *)objects;

    if ([tables count] < 2) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        return nil;
    }
    
    NSArray *days = [[[tables objectAtIndex:0] valueForKey:@"tbody"] valueForKey:@"tr"];

    NSInteger i = 0;
    for (NSDictionary * day in days) {
        if (i++ == 0) continue;
        if ([day[@"td"] count] != 4) continue;
        
        NSString *date = day[@"td"][1];
        if ([date isEqualToString:@"Journée en cours"]) date = [self.dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.dateFormatter dateFromString:date]];
        
        [entry setValue:[[day valueForKey:@"td"]objectAtIndex:0] forKey:@"port"];
        [entry setValue:date forKey:@"date"];
        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:2]valueForKey:@"content" ] forKey:@"upload"];
        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:3]valueForKey:@"content" ] forKey:@"download"];
        [entry setValue:[@([components month]) stringValue] forKey:@"month"];
        [entry setValue:[NSString stringWithFormat:@"%@-%@", [[day valueForKey:@"td"]objectAtIndex:0], date] forKey:@"id"];
        [entries addObject:entry];
    }
    
    return entries;
}

@end
