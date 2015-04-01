//
//  ETSUniversityCalendarViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-23.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSUniversityCalendarViewController.h"
#import "ETSEvent.h"

@interface ETSUniversityCalendarViewController ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

NSString * const ETSUniversityCalendarSource = @"ets";

@implementation ETSUniversityCalendarViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
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
    self.dateFormatter.dateFormat = @"EEEE d MMMM";
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

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                               fromDate:event.start
                                                 toDate:event.end
                                                options:0];
    if (components.day < 2) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Le %@", [self.dateFormatter stringFromDate:event.start]];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Du %@ au %@", [self.dateFormatter stringFromDate:event.start], [self.dateFormatter stringFromDate:event.end]];
    }
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
