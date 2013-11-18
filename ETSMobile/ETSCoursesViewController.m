//
//  ETSCoursesViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-10-20.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSCoursesViewController.h"
#import "ETSCourse.h"
#import "ETSAuthenticationViewController.h"
#import "ETSCourseCell.h"
#import "ETSSessionHeader.h"
#import "NSURLRequest+API.h"
#import "UIStoryboard+ViewController.h"
#import "ETSCourseDetailViewController.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>


@interface ETSCoursesViewController ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation ETSCoursesViewController

@synthesize fetchedResultsController=_fetchedResultsController;

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  NSLocalizedString(@"Notes", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];
    
    
    self.cellIdentifier = @"CourseIdentifier";
    
    ETSConnection *connection = [[ETSConnection alloc] init];
    connection.request = [NSURLRequest requestForCourses];
    connection.entityName = @"Course";
    connection.compareKey = @"acronym";
    connection.objectsKeyPath = @"d.liste";
    self.connection = connection;
    self.connection.delegate = self;
    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        ETSAuthenticationViewController *ac = [self.storyboard instantiateAuthenticationViewController];
        ac.delegate = self;
        [self.navigationController pushViewController:ac animated:YES];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    fetchRequest.fetchLimit = 24;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"acronym" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"order" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;

    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    ETSCourseCell *courseCell = (ETSCourseCell *)cell;
    courseCell.gradeLabel.text = course.grade;
    
//    NSMutableString *Var_1 =[NSMutableString stringWithCapacity:0];
//    [Var_1 setString:course.acronym];
//    [Var_1 appendString:@"\n,"];
    
    courseCell.acronymLabel.text = course.acronym;
    
   
    
    courseCell.layer.cornerRadius = 2.0f;
    courseCell.layer.borderColor = [UIColor colorWithRed:190.0f/255.0f green:0.0f/255.0f blue:10.0f/255.0f alpha:1].CGColor;
    courseCell.layer.borderWidth = 1.0f;
    //courseCell.lay
}

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor lightGrayColor];
}

- (void)collectionView:(UICollectionView *)colView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        ETSSessionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SessionHeaderIdentifier" forIndexPath:indexPath];
        
        CALayer *topBorder = [CALayer layer];
        topBorder.frame = CGRectMake(0.0f, 0.0f, headerView.frame.size.width, 0.5f);
        topBorder.backgroundColor = [UIColor lightGrayColor].CGColor;
        [headerView.layer addSublayer:topBorder];

        
        ETSCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSString *session = nil;
        if ([course.season integerValue] == 1)      session = NSLocalizedString(@"Hiver", nil);
        else if ([course.season integerValue] == 2) session = NSLocalizedString(@"Été", nil);
        else if ([course.season integerValue] == 3) session = NSLocalizedString(@"Automne", nil);
        
        headerView.sessionLabel.text = [NSString stringWithFormat:@"%@ %@", session, course.year];
        
        return headerView;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ETSCourseDetailViewController *vc = [segue destinationViewController];
    vc.course = [self.fetchedResultsController objectAtIndexPath:[[self.collectionView indexPathsForSelectedItems] objectAtIndex:0]];
    vc.managedObjectContext = self.managedObjectContext;
}

- (void)connection:(ETSConnection *)connection didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSCourse *course = (ETSCourse *)managedObject;
    course.year = @([[object[@"session"] substringFromIndex:1] integerValue]);
    
    NSString *seasonString = [object[@"session"] substringToIndex:1];
    if ([seasonString isEqualToString:@"H"])      course.season = @1;
    else if ([seasonString isEqualToString:@"É"]) course.season = @2;
    else if ([seasonString isEqualToString:@"A"]) course.season = @3;
    
    if ([seasonString isEqualToString:@"H"])      course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"1"];
    else if ([seasonString isEqualToString:@"É"]) course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"2"];
    else if ([seasonString isEqualToString:@"A"]) course.order = [NSString stringWithFormat:@"%@-%@", course.year, @"3"];
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.connection.request = [NSURLRequest requestForCourses];
    [super controllerDidAuthenticate:controller];
}

@end
