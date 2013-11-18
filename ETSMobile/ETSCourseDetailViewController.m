//
//  ETSCourseDetailViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-06.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCourseDetailViewController.h"
#import "NSURLRequest+API.h"
#import "ETSEvaluation.h"

@interface ETSCourseDetailViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@end

@implementation ETSCourseDetailViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"EvaluationIdentifier";
    
    ETSConnection *connection = [[ETSConnection alloc] init];
    connection.request = [NSURLRequest requestForEvaluationsWithCourse:self.course];
    connection.entityName = @"Evaluation";
    connection.compareKey = @"name";
    connection.objectsKeyPath = @"d.liste";
    connection.predicate = [NSPredicate predicateWithFormat:@"course.acronym == %@", self.course.acronym];
    self.connection = connection;
    self.connection.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.maximumFractionDigits = 1;
    self.formatter.minimumFractionDigits = 1;
    
    self.title = self.course.acronym;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Evaluation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchLimit = 10;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"course.acronym == %@", self.course.acronym];
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return [self.course.grade length] > 0 ? 6 : 5;
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Sommaire", nil);
    else if (section == 1)  return NSLocalizedString(@"Évaluations", nil);
    return nil;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        ETSEvaluation *evaluation = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        cell.textLabel.text = evaluation.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:evaluation.result], [self.formatter stringFromNumber:evaluation.total]];
    }
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Note à ce jour", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:self.course.results], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]]];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Moyenne du groupe", nil);
            cell.detailTextLabel.text = [self.formatter stringFromNumber:self.course.mean];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Écart-type", nil);
            cell.detailTextLabel.text = [self.formatter stringFromNumber:self.course.std];
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Médiane", nil);
            cell.detailTextLabel.text = [self.formatter stringFromNumber:self.course.median];
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Rang centile", nil);
            cell.detailTextLabel.text = [self.course.percentile stringValue];
        }
        else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Cote au dossier", nil);
            cell.detailTextLabel.text = self.course.grade;
        }
    }
}

- (void)connection:(ETSConnection *)connection didReceiveDictionary:(NSDictionary *)dictionary
{
    NSDictionary *results = [dictionary objectForKey:@"d"];
    self.course.results     = [self.formatter numberFromString:[results objectForKey:@"noteACeJour"]];
    self.course.mean        = [self.formatter numberFromString:[results objectForKey:@"moyenneClasse"]];
    self.course.std         = [self.formatter numberFromString:[results objectForKey:@"ecartTypeClasse"]];
    self.course.median      = [self.formatter numberFromString:[results objectForKey:@"medianeClasse"]];
    self.course.percentile  = [self.formatter numberFromString:[results objectForKey:@"rangCentileClasse"]];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSEvaluation *evaluation = (ETSEvaluation *)managedObject;
    evaluation.course = self.course;
    evaluation.ignored = [[object objectForKey:@"ignoreDuCalcul"] isEqualToString:@"Non"] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES];
}

- (void)connectionDidFinishLoading:(ETSConnection *)connection
{
    
}

@end
