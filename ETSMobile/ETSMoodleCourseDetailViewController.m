//
//  ETSMoodleCourseDetailViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSMoodleCourseDetailViewController.h"
#import "ETSMoodleElement.h"
#import "MFSideMenu.h"

@implementation ETSMoodleCourseDetailViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    [self.synchronization synchronize:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"MOODLE_DETAIL_VIEWCONTROLLER"];
    
    self.cellIdentifier = @"MoodleIdentifier";
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    if (self.token && [self.token length] > 0) {
        [self initializeSynchronization];
    }
}

- (void)initializeSynchronization
{
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForMoodleCourseDetailWithToken:self.token courseid:[self.course.id stringValue]];
    synchronization.entityName = @"MoodleElement";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"";
    synchronization.predicate = [NSPredicate predicateWithFormat:@"course.id == %@", self.course.id];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.synchronization synchronize:nil];
}

- (void)refreshView
{
    [self initializeSynchronization];
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodleElement" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"parentid" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[[NSPredicate predicateWithFormat:@"visible == YES"], [NSPredicate predicateWithFormat:@"course.id == %@", self.course.id]]];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"parentid" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if ([objects isKindOfClass:[NSDictionary class]]) return @[];
    
    NSMutableArray *elements = [NSMutableArray array];

    for (NSDictionary *module in objects) {
        if (!module[@"modules"]) continue;
        
        for (NSDictionary *element in module[@"modules"]) {
            if ([element[@"modname"] isEqualToString:@"label"]) continue;
            
            NSMutableDictionary *parsedElement = [NSMutableDictionary dictionary];
            if (module[@"id"])          parsedElement[@"parentid"]  = module[@"id"];
            if (module[@"name"])        parsedElement[@"header"]    = module[@"name"];
            if (element[@"id"])         parsedElement[@"id"]        = element[@"id"];
            if (element[@"modname"])    parsedElement[@"type"]      = element[@"modname"];
            if (element[@"name"])       parsedElement[@"name"]      = element[@"name"];
            if (element[@"visible"])    parsedElement[@"visible"]   = element[@"visible"];
            if (element[@"contents"][0]) {
                if (element[@"contents"][0][@"filename"])  parsedElement[@"filename"]  = element[@"contents"][0][@"filename"];
                if (element[@"contents"][0][@"fileurl"])   parsedElement[@"url"]       = element[@"contents"][0][@"fileurl"];
            } else {
                if (element[@"url"]) parsedElement[@"url"] = element[@"url"];
            }
            [elements addObject:parsedElement];
        }
    }

    return elements;
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSMoodleElement *element = (ETSMoodleElement *)managedObject;
    element.course = (ETSMoodleCourse *)[element.managedObjectContext objectWithID:[self.course objectID]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return element.header;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.textLabel.text = element.name;
    if ([element.type isEqualToString:@"resource"] && !self.token) {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ETSMoodleElement *element = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([element.type isEqualToString:@"resource"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@&token=%@", element.url, self.token]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:element.url]];
    }
}

@end
