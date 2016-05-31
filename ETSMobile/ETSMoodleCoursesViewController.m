//
//  ETSMoodleCoursesViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSMoodleCoursesViewController.h"
#import "ETSMoodleCourseDetailViewController.h"
#import "ETSMoodleCourse.h"
#import "ETSMenuViewController.h"

#import <Crashlytics/Crashlytics.h>

NSString * const kUnknownSession = @"000000";

@interface ETSMoodleCoursesViewController ()

@property (nonatomic, copy)   NSString *token;
@property (nonatomic, copy)   NSString *userid;
@property (nonatomic, strong) NSDate   *tokenExpiration;

@end


@implementation ETSMoodleCoursesViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
    [self.synchronization synchronize:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"MoodleIdentifier";

    [self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
    if (![ETSAuthenticationViewController passwordInKeychain] || ![ETSAuthenticationViewController usernameInKeychain]) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            ac.delegate = self;
            [self.navigationController pushViewController:ac animated:NO];
        } else {
            UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
            ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
            authenticationController.delegate = self;
            navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
            navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController presentViewController:navigationController animated:NO completion:nil];
        }
    } else {
        [self requestTokenAndUserID];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Moodle courses"
                        contentType:@"Moodle"
                          contentId:@"ETS-Moodle"
                   customAttributes:@{}];
    
    if (!self.token && ![[self.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
        [self requestTokenAndUserID];
    }
}

- (void)requestTokenAndUserID
{
    NSMutableURLRequest *requestForToken = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ena.etsmtl.ca/login/token.php"]];
    NSString *parametersForToken = [NSString stringWithFormat:@"username=%@&password=%@&service=moodle_mobile_app", [ETSAuthenticationViewController usernameInKeychain], [ETSAuthenticationViewController passwordInKeychain]];
    [requestForToken setHTTPBody:[parametersForToken dataUsingEncoding:NSUTF8StringEncoding]];
    [requestForToken setHTTPMethod:@"POST"];
    
    __weak typeof(self) bself = self;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask *taskForToken = [[NSURLSession sharedSession] dataTaskWithRequest:requestForToken completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
          if (jsonObject[@"token"] && [jsonObject[@"token"] length] > 0) {
              if ([[bself.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]]) {
                  dispatch_sync(dispatch_get_main_queue(), ^{
                      [bself.navigationController popViewControllerAnimated:YES];
                  });
              }
              
              if ([[bself.navigationController topViewController] isKindOfClass:[ETSMoodleCourseDetailViewController class]]) {
                  ((ETSMoodleCourseDetailViewController *)[bself.navigationController topViewController]).token = jsonObject[@"token"];
                  dispatch_sync(dispatch_get_main_queue(), ^{
                      [((ETSMoodleCourseDetailViewController *)[bself.navigationController topViewController]) refreshView];
                  });
              }
              bself.token = jsonObject[@"token"];
              bself.tokenExpiration = [NSDate dateWithTimeIntervalSinceNow:30*60];
              
              NSMutableURLRequest *requestForUserID = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://ena.etsmtl.ca/webservice/rest/server.php?moodlewsrestformat=json"]];
              NSString *parametersForUserID = [NSString stringWithFormat:@"wsfunction=moodle_webservice_get_siteinfo&wstoken=%@", jsonObject[@"token"]];
              [requestForUserID setHTTPBody:[parametersForUserID dataUsingEncoding:NSUTF8StringEncoding]];
              [requestForUserID setHTTPMethod:@"POST"];
              
              NSURLSessionDataTask *taskForUserID = [[NSURLSession sharedSession] dataTaskWithRequest:requestForUserID completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                  if (jsonObject[@"userid"]) {
                      if ([jsonObject[@"userid"] isKindOfClass:[NSNumber class]]) bself.userid = [jsonObject[@"userid"] stringValue];
                      else if ([jsonObject[@"userid"] isKindOfClass:[NSString class]]) bself.userid = jsonObject[@"userid"];
                      
                      if (bself.userid) {
                          [bself initializeSynchronisation];
                      }
                  }
              }];
              [taskForUserID resume];
          } else if (jsonObject[@"error"]) {
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              bself.token = nil;
              bself.tokenExpiration = nil;
              bself.userid = nil;
              
              if ([[bself.navigationController topViewController] isKindOfClass:[ETSAuthenticationViewController class]] || self.presentedViewController) {
                  UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentification", nil) message:NSLocalizedString(@"Code d’accès ou mot de passe invalide", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                  dispatch_sync(dispatch_get_main_queue(), ^{
                      [av show];
                  });
              }
              else {
                  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                      ETSAuthenticationViewController *ac = [bself.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                      ac.delegate = bself;
                      dispatch_sync(dispatch_get_main_queue(), ^{
                          [bself.navigationController pushViewController:ac animated:YES];
                      });
                  } else {
                      UINavigationController *navigationController = [bself.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
                      ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
                      authenticationController.delegate = bself;
                      navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                      navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                      dispatch_sync(dispatch_get_main_queue(), ^{
                          [bself.navigationController presentViewController:navigationController animated:NO completion:nil];
                      });
                  }
                  
                  
              }
          } else {
              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              bself.token = nil;
              bself.tokenExpiration = nil;
              bself.userid = nil;
          }
      }];
    [taskForToken resume];
}

- (void)initializeSynchronisation
{
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForMoodleCoursesWithToken:self.token userid:self.userid];
    synchronization.entityName = @"MoodleCourse";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"";
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    [self.synchronization synchronize:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MoodleCourse" inManagedObjectContext:self.managedObjectContext];
    
    fetchRequest.entity = entity;
    fetchRequest.fetchBatchSize = 20;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"session" ascending:NO], [NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"visible == YES"];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"session" cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        // FIXME: Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSMoodleCourse *course = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = course.acronym;
    cell.detailTextLabel.text = course.name;
}

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    ETSMoodleCourse *course = (ETSMoodleCourse *)managedObject;
    NSString *searchedString = course.shortname;
    NSRange   searchedRange = NSMakeRange(0, [searchedString length]);
    
    NSString *pattern = @"S20[0-9][0-9][0-9]";
    NSError *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            course.session = [searchedString substringWithRange:[match range]];
            break;
        }
    }
    
    pattern = @"[A-Z][A-Z][A-Z][0-9][0-9][0-9]";
    error = nil;
    regex = [NSRegularExpression regularExpressionWithPattern: pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        NSArray* matches = [regex matchesInString:searchedString options:0 range: searchedRange];
        for (NSTextCheckingResult* match in matches) {
            course.acronym = [searchedString substringWithRange:[match range]];
            break;
        }
    }
    
    pattern = @"[A-Z][A-Z][A-Z][0-9][0-9][0-9][\\-0-90-9]+\\s";
    error = nil;
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        course.name = [regex stringByReplacingMatchesInString:course.fullname options:0 range:NSMakeRange(0, [course.fullname length]) withTemplate:@""];

        pattern = @"\\s\\([A|É|H][0-9][0-9][0-9][0-9]\\)";
        error = nil;
        regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error) {
            course.name = [regex stringByReplacingMatchesInString:course.name options:0 range:NSMakeRange(0, [course.name length]) withTemplate:@""];
        }
    }
    
    if (!course.session || [course.session length] == 0) {
        course.session = kUnknownSession;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    ETSMoodleCourse *course = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    
    if ([course.session isEqualToString:kUnknownSession]) return NSLocalizedString(@"Session inconnue", nil);
    
    NSString *session = @"";
    NSRange sessionRange = NSMakeRange(5, 1);
    if ([[course.session substringWithRange:sessionRange] isEqualToString:@"1"])      session = NSLocalizedString(@"Hiver", nil);
    else if ([[course.session substringWithRange:sessionRange] isEqualToString:@"2"]) session = NSLocalizedString(@"Été", nil);
    else if ([[course.session substringWithRange:sessionRange]  isEqualToString:@"3"]) session = NSLocalizedString(@"Automne", nil);
    
    NSString *year = [course.session substringWithRange:NSMakeRange(1, 4)];
    
    return [NSString stringWithFormat:@"%@ %@", session, year];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ETSMoodleCourseDetailViewController class]]) {
        ETSMoodleCourse *course = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        ((ETSMoodleCourseDetailViewController *)segue.destinationViewController).token = self.token;
        ((ETSMoodleCourseDetailViewController *)segue.destinationViewController).course = course;
        ((ETSMoodleCourseDetailViewController *)segue.destinationViewController).title = course.acronym;
        ((ETSMoodleCourseDetailViewController *)segue.destinationViewController).managedObjectContext = self.managedObjectContext;
    }
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return ETSSynchronizationResponseValid;
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller;
{
    [self requestTokenAndUserID];
}

@end
