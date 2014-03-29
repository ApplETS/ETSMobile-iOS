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
#import "ETSEvaluationCell.h"

@interface ETSCourseDetailViewController ()
@property (nonatomic, strong) ETSCourse *courseForSynchronization;
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, assign) BOOL hadResults;
@end

@implementation ETSCourseDetailViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)startRefresh:(id)sender
{
    NSError *error;
    [self.synchronization synchronize:&error];
    self.courseForSynchronization = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.courseForSynchronization = nil;
    
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
    
    self.hadResults = [[self.fetchedResultsController sections][0] numberOfObjects] > 0;
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
    return self.hadResults + (self.course.grade && [self.course.grade length] > 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        NSInteger rows = 0;
        if (self.hadResults) rows = 5;
        if (self.course.grade && [self.course.grade length] > 0) rows++;
        return rows;
    }
    
    return [[self.fetchedResultsController sections][0] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)       return NSLocalizedString(@"Sommaire", nil);
    else if (section == 1)  return NSLocalizedString(@"Évaluations", nil);
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"EvaluationIdentifier" forIndexPath:indexPath];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"EvaluationDetailsIdentifier" forIndexPath:indexPath];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) return 44;
    else return 146;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        ETSEvaluation *evaluation = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        ((ETSEvaluationCell *)cell).nameLabel.text = evaluation.name;
        ((ETSEvaluationCell *)cell).resultLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:evaluation.result], [self.formatter stringFromNumber:evaluation.total]];
        ((ETSEvaluationCell *)cell).meanLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:evaluation.mean], [self.formatter stringFromNumber:evaluation.total]];
        ((ETSEvaluationCell *)cell).medianLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:evaluation.median], [self.formatter stringFromNumber:evaluation.total]];
        ((ETSEvaluationCell *)cell).stdLabel.text = [self.formatter stringFromNumber:evaluation.std];
        ((ETSEvaluationCell *)cell).percentileLabel.text = [self.formatter stringFromNumber:evaluation.percentile];
    }
    else {
        if (indexPath.row == 0 && self.hadResults > 0) {
                cell.textLabel.text = NSLocalizedString(@"Note à ce jour", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:self.course.resultOn100], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]]];
        }
        else if (indexPath.row == 0 && self.hadResults == 0) {
            cell.textLabel.text = NSLocalizedString(@"Cote au dossier", nil);
            cell.detailTextLabel.text = self.course.grade;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Moyenne du groupe", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:self.course.mean], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]]];
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Médiane", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@", [self.formatter stringFromNumber:self.course.median], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]]];
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Écart-type", nil);
            cell.detailTextLabel.text = [self.formatter stringFromNumber:self.course.std];
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
    self.course.resultOn100 = [self.formatter numberFromString:results[@"scoreFinalSur100"]];
    self.course.results     = [self.formatter numberFromString:results[@"noteACeJour"]];
    self.course.mean        = [self.formatter numberFromString:results[@"moyenneClasse"]];
    self.course.std         = [self.formatter numberFromString:results[@"ecartTypeClasse"]];
    self.course.median      = [self.formatter numberFromString:results[@"medianeClasse"]];
    self.course.percentile  = [self.formatter numberFromString:results[@"rangCentileClasse"]];
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    if (!self.courseForSynchronization) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Course"];
        
        request.predicate = [NSPredicate predicateWithFormat:@"acronym == %@", self.course.acronym];

        NSError *error = nil;
        NSArray *courseObjets = [managedObject.managedObjectContext executeFetchRequest:request error:&error];

        if ([courseObjets count] > 0) {
            self.courseForSynchronization = courseObjets[0];
        }
    }
    
    if (self.courseForSynchronization) {
        ETSEvaluation *evaluation = (ETSEvaluation *)managedObject;
        evaluation.course = self.courseForSynchronization;
        evaluation.ignored = [object[@"ignoreDuCalcul"] isEqualToString:@"Non"] ? @NO : @YES;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    if (!self.hadResults) [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section + 1];
    if (newIndexPath) {
        newIndexPath = [NSIndexPath indexPathForRow:newIndexPath.row inSection:newIndexPath.section + 1];
    }
    
    [super controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.hadResults) {
        self.hadResults = YES;
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0],
                                                 [NSIndexPath indexPathForRow:1 inSection:0],
                                                 [NSIndexPath indexPathForRow:2 inSection:0],
                                                 [NSIndexPath indexPathForRow:3 inSection:0],
                                                 [NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [super controllerDidChangeContent:controller];
}


@end
