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
#import "UIScrollView+EmptyDataSet.h"
#import "ETSSession.h"
#import <Crashlytics/Crashlytics.h>

@interface ETSCourseDetailViewController () <DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, strong) NSNumberFormatter *formatterPourcent;
@property (nonatomic, strong) UIBarButtonItem *coursesBarButtonItem;
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
    
    if (self.course && self.course.acronym.length > 0) {
        ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
        synchronization.request = [NSURLRequest requestForEvaluationsWithCourse:self.course];
        synchronization.entityName = @"Evaluation";
        synchronization.compareKey = @"name";
        synchronization.objectsKeyPath = @"d.liste";
        synchronization.sortSelector = @selector(localizedCaseInsensitiveCompare:);
        synchronization.predicate = [NSPredicate predicateWithFormat:@"course.id == %@", self.course.id];
        self.synchronization = synchronization;
        self.synchronization.delegate = self;
    }
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.maximumFractionDigits = 1;
    self.formatter.minimumFractionDigits = 1;
    self.formatter.minimumIntegerDigits = 1;
    
    _formatterPourcent = [[NSNumberFormatter alloc] init];
    [_formatterPourcent setNumberStyle:NSNumberFormatterPercentStyle];
    [_formatterPourcent setMaximumFractionDigits:0];
    [_formatterPourcent setMultiplier:@1];
    
    self.formatterPourcent.formatterBehavior = NSNumberFormatterPercentStyle;
    
    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.title = self.course.acronym;
    
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.hadResults = [[self.fetchedResultsController sections][0] numberOfObjects] > 0;
}

- (NSAttributedString *)titleforEvaluationNotCompleted: (UIScrollView *)scrollView
{
    NSString *text = @"Veuillez compléter l'évaluation de ce cours avant de pouvoir accéder à vos notes";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"Aucune note disponible pour le moment.";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"ico_notes"];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Courses notes details"
                        contentType:@"Courses"
                          contentId:@"ETS-Courses-Details"
                   customAttributes:@{}];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  //  [self.coursesBarButtonItem.target performSelector:self.coursesBarButtonItem.action withObject:self.coursesBarButtonItem];
#pragma clang diagnostic pop
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!self.course) return nil;
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Evaluation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 10;
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"course == %@", self.course];
    
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
    if (self.hadResults) return 2;
    else if (self.course.grade && [self.course.grade length] > 0) return 1;
    else return 0;
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
    else return 171;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        ETSEvaluation *evaluation = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        ((ETSEvaluationCell *)cell).nameLabel.text = evaluation.name;
        NSNumber *percentResult = @([evaluation.result floatValue]/[evaluation.total floatValue]*100);
        ((ETSEvaluationCell *)cell).resultLabel.text = [NSString stringWithFormat:@"%@/%@ (%@)", [self.formatter stringFromNumber:evaluation.result], [self.formatter stringFromNumber:evaluation.total], [self.formatterPourcent stringFromNumber:percentResult]];
        NSNumber *percentMean = @([evaluation.mean floatValue]/[evaluation.total floatValue]*100);
        ((ETSEvaluationCell *)cell).meanLabel.text = [NSString stringWithFormat:@"%@", [self.formatterPourcent stringFromNumber:percentMean]];
        NSNumber *percentMedian = @([evaluation.median floatValue]/[evaluation.total floatValue]*100);
        ((ETSEvaluationCell *)cell).medianLabel.text = [NSString stringWithFormat:@"%@", [self.formatterPourcent stringFromNumber:percentMedian]];
        ((ETSEvaluationCell *)cell).stdLabel.text = [self.formatter stringFromNumber:evaluation.std];
        ((ETSEvaluationCell *)cell).percentileLabel.text = [self.formatter stringFromNumber:evaluation.percentile];
        ((ETSEvaluationCell *)cell).weightingLabel.text = [NSString stringWithFormat:@"%@", [self.formatterPourcent stringFromNumber:evaluation.weighting]];
    }
    else {
        if (indexPath.row == 0 && self.hadResults > 0) {
                cell.textLabel.text = NSLocalizedString(@"Note à ce jour", nil);
                NSNumber *percentNote = @([self.course.resultOn100 floatValue]/[self.course.totalEvaluationWeighting floatValue]*100);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@ (%@)", [self.formatter stringFromNumber:self.course.resultOn100], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]], [self.formatterPourcent stringFromNumber:percentNote]];
        }
        else if (indexPath.row == 0 && self.hadResults == 0) {
            cell.textLabel.text = NSLocalizedString(@"Cote au dossier", nil);
            cell.detailTextLabel.text = self.course.grade;
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Moyenne du groupe", nil);
            NSNumber *percentMoyenne = @([self.course.mean floatValue]/[self.course.totalEvaluationWeighting floatValue]*100);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@ (%@)", [self.formatter stringFromNumber:self.course.mean], [self.formatter stringFromNumber:[self.course totalEvaluationWeighting]], [self.formatterPourcent stringFromNumber:percentMoyenne]];
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
    // NSManagedObjectContext can be nil (Apple Documentation).
    // Need to check for that before using the object.
    if (self.course.managedObjectContext != nil) {
        NSError *error;
        [self.course.managedObjectContext save:&error];
        if (error != nil) {
            NSLog(@"Unresolved error: %@", error);
        }
    }
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSEvaluation *evaluation = (ETSEvaluation *)managedObject;
    NSError *error;
//    evaluation.course = (ETSCourse *)[evaluation.managedObjectContext objectWithID:[self.course objectID]];
    evaluation.course = (ETSCourse *)[evaluation.managedObjectContext existingObjectWithID:[self.course objectID] error:&error];
    if (error != nil) {
        NSLog(@"Unresolved error: %@", error);
    }
    evaluation.ignored = [object[@"ignoreDuCalcul"] isEqualToString:@"Non"] ? @NO : @YES;
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
    [super synchronizationDidFinishLoading:synchronization];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if ([self.tableView numberOfSections] > 0)
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
    if (!self.hadResults) {
        if ([self.tableView numberOfSections] == 0) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationAutomatic];
        } else {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
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
    } else {
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
        [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    }
    [super controllerDidChangeContent:controller];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.coursesBarButtonItem = barButtonItem;
    barButtonItem.title = NSLocalizedString(@"Cours", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)coursesViewController:(ETSCoursesViewController_iPad *)controller didSelectCourse:(ETSCourse *)course managedObjectContext:(NSManagedObjectContext *)context
{
    self.managedObjectContext = context;
    self.course = course;
    
    self.synchronization.delegate = nil;
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForEvaluationsWithCourse:self.course];
    synchronization.entityName = @"Evaluation";
    synchronization.compareKey = @"name";
    synchronization.objectsKeyPath = @"d.liste";
    synchronization.predicate = [NSPredicate predicateWithFormat:@"course == %@", self.course];
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.fetchedResultsController = nil;
    self.hadResults = [[self.fetchedResultsController sections][0] numberOfObjects] > 0;

    self.title = course.title;
    
    [self.tableView reloadData];
    [self startRefresh:nil];
}

@end
