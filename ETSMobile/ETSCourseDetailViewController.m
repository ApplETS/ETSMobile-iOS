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
@property (nonatomic, assign) BOOL hadResults;
@end

@implementation ETSCourseDetailViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"EvaluationIdentifier";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForEvaluationsWithCourse:self.course];
    synchronization.entityName = @"Evaluation";
    synchronization.compareKey = @"name";
    synchronization.objectsKeyPath = @"d.liste";
    synchronization.predicate = [NSPredicate predicateWithFormat:@"course.acronym == %@", self.course.acronym];
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.maximumFractionDigits = 1;
    self.formatter.minimumFractionDigits = 1;
    self.formatter.minimumIntegerDigits = 1;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = self.course.acronym;
    
    self.hadResults = [self.course.results floatValue] > 0;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Evaluation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 10;
    
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
    if (section == 0) {
        if ([self.course.results floatValue] > 0) return [self.course.grade length] > 0 ? 6 : 5;
        else return [self.course.grade length] > 0 ? 1 : 0;
    }
    
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            if ([self.course.results floatValue] == 0) {
                cell.textLabel.text = NSLocalizedString(@"Cote au dossier", nil);
                cell.detailTextLabel.text = self.course.grade;
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"Note à ce jour", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:self.course.results], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]]];
            }
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

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveDictionary:(NSDictionary *)dictionary
{
    NSDictionary *results = dictionary[@"d"];
    self.course.results     = [self.formatter numberFromString:results[@"noteACeJour"]];
    self.course.mean        = [self.formatter numberFromString:results[@"moyenneClasse"]];
    self.course.std         = [self.formatter numberFromString:results[@"ecartTypeClasse"]];
    self.course.median      = [self.formatter numberFromString:results[@"medianeClasse"]];
    self.course.percentile  = [self.formatter numberFromString:results[@"rangCentileClasse"]];
    
    if (!self.hadResults && [self.course.results floatValue] > 0) {
        NSInteger offset = 0;
        if ([self.course.grade length] > 0) offset = 1;
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0+offset inSection:0],
                                                 [NSIndexPath indexPathForRow:1+offset inSection:0],
                                                 [NSIndexPath indexPathForRow:2+offset inSection:0],
                                                 [NSIndexPath indexPathForRow:3+offset inSection:0],
                                                 [NSIndexPath indexPathForRow:4+offset inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        self.hadResults = YES;
    }
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSEvaluation *evaluation = (ETSEvaluation *)managedObject;
    evaluation.course = self.course;
    evaluation.ignored = [object[@"ignoreDuCalcul"] isEqualToString:@"Non"] ? @NO : @YES;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    if (newIndexPath) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];
    }
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}
//FIXME
/*
- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    [super connectionDidFinishLoading:synchronization];
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    for (NSInteger i = 0; i < rows; i++) {
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    }
}
*/
@end
