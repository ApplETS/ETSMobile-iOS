//
//  ETSUniversityCalendarViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-23.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSUniversityCalendarViewController.h"
#import "ETSEvent.h"

#import <Crashlytics/Crashlytics.h>

@interface ETSUniversityCalendarViewController ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

NSString * const ETSUniversityCalendarSource = @"ets";

@implementation ETSUniversityCalendarViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.start) {
        self.start = [NSDate date];
    }
    
    if (!self.end) {
        NSDateComponents *monthComponent = [NSDateComponents new];
        monthComponent.month = 4;
        self.end = [[NSCalendar currentCalendar] dateByAddingComponents:monthComponent toDate:self.start options:0];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];

    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForUniversityCalendarStart:self.start end:self.end];
    synchronization.entityName = @"Event";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"data.ets";
    synchronization.appletsServer = YES;
    synchronization.predicate = [NSPredicate predicateWithFormat:@"source ==[c] %@", ETSUniversityCalendarSource];
    synchronization.dateFormatter = dateFormatter;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.cellIdentifier = @"EventIdentifier";
    
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    self.dateFormatter.dateFormat = @"EEEE d MMMM";

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"University calendar"
                        contentType:@"Calendar"
                          contentId:@"ETS-University-Calendar"
                   customAttributes:@{}];
}

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
	fetchRequest.fetchBatchSize = 10;
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"start" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"end" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"source ==[c] %@", ETSUniversityCalendarSource], [NSPredicate predicateWithFormat:@"start >= %@", self.start]]];
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	self.fetchedResultsController = aFetchedResultsController;
	_fetchedResultsController.delegate = self;
    
	NSError *error;
	if (![_fetchedResultsController performFetch:&error]) {
		// FIXME: Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
	return _fetchedResultsController;
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ((ETSEvent *)managedObject).source = ETSUniversityCalendarSource;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = event.title;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:event.start
                                                 toDate:event.end
                                                options:0];
    
    //Detail label
    if (components.day < 2) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Le %@", [self.dateFormatter stringFromDate:event.start]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Du %@ au %@", [self.dateFormatter stringFromDate:event.start], [self.dateFormatter stringFromDate:[event.end dateByAddingTimeInterval:-1]]];
    }
    
    //Urgent date verification
    NSDate *now = [NSDate date];
    if ([now compare:event.start] == NSOrderedDescending && [now compare:event.end] == NSOrderedAscending) {
        cell.backgroundColor = [UIColor colorWithRed:176/255.0f green:0 blue:16/255.0f alpha:0.05];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

@end
