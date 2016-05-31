//
//  ETSProfileViewController.m
//  ETSMobile
//
//  Created by Annie Caron on 11/17/2013.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSProfileViewController.h"
#import "ETSMenuViewController.h"
#import "NSURLRequest+API.h"
#import "ETSProfile.h"
#import "ETSProgram.h"
#import "ETSCoreDataHelper.h"

#import <Crashlytics/Crashlytics.h>

@interface ETSProfileViewController ()
@property (nonatomic, strong) NSNumberFormatter *formatter;
@property (nonatomic, assign) BOOL hadResults;
@property (nonatomic, strong) ETSSynchronization *synchronizationProgram;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerProfile;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsControllerProgram;
@property (assign) NSInteger synchronizationDone;
@property (assign, nonatomic) BOOL isCleaning;
@end

@implementation ETSProfileViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)startRefresh:(id)sender
{
	self.synchronizationDone = 0;
	NSError *errorProfile;
	[self.synchronization synchronize:&errorProfile];
	NSError *errorProgram;
	[self.synchronizationProgram synchronize:&errorProgram];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    #ifdef __USE_TESTFLIGHT
	[TestFlight passCheckpoint:@"PROFILE_VIEWCONTROLLER"];
    #endif
    
	self.cellIdentifier = @"ProfileIdentifier";
	self.synchronizationDone = 0;
    
	ETSSynchronization *synchronizationProfile = [[ETSSynchronization alloc] init];
	synchronizationProfile.request = [NSURLRequest requestForProfile];
	synchronizationProfile.entityName = @"Profile";
	synchronizationProfile.compareKey = @"permanentCode";
	synchronizationProfile.objectsKeyPath = @"d";
	synchronizationProfile.saveAutomatically = NO;
    
	self.synchronization = synchronizationProfile;
	self.synchronization.delegate = self;
    
	ETSSynchronization *synchronizationProgram = [[ETSSynchronization alloc] init];
	synchronizationProgram.request = [NSURLRequest requestForProgram];
	synchronizationProgram.entityName = @"Program";
	synchronizationProgram.compareKey = @"code";
	synchronizationProgram.objectsKeyPath = @"d.liste";
	synchronizationProgram.saveAutomatically = NO;
    
	self.synchronizationProgram = synchronizationProgram;
	self.synchronizationProgram.delegate = self;
    
	self.formatter = [[NSNumberFormatter alloc] init];
	self.formatter.decimalSeparator = @",";
	self.formatter.groupingSeparator = @" ";
	self.formatter.groupingSize = 3;
	self.formatter.usesGroupingSeparator = YES;
	self.formatter.maximumFractionDigits = 2;
	self.formatter.minimumFractionDigits = 2;
	self.formatter.minimumIntegerDigits = 1;
    
	[self.refreshControl addTarget:self action:@selector(startRefresh:) forControlEvents:UIControlEventValueChanged];
    
	self.title = @"Profil";
    
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
	}
    
	self.isCleaning = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.synchronizationDone = 0;
    
	if (self.isCleaning) {
		self.fetchedResultsControllerProgram.delegate = nil;
		self.fetchedResultsControllerProfile.delegate = nil;
		self.fetchedResultsControllerProgram = nil;
		self.fetchedResultsControllerProfile = nil;
		[self.tableView reloadData];
		self.isCleaning = NO;
	}
    
	[super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Profile"
                        contentType:@"Profile"
                          contentId:@"ETS-Profile"
                   customAttributes:@{}];
    
	NSError *error;
	[self.synchronizationProgram synchronize:&error];
}

- (void)viewDidDisappear:(BOOL)animated
{
	self.fetchedResultsControllerProfile.delegate = nil;
	self.fetchedResultsControllerProgram.delegate = nil;
	[super viewDidDisappear:animated];
}

- (NSFetchedResultsController *)fetchedResultsControllerProfile
{
	if (_fetchedResultsControllerProfile != nil) {
		return _fetchedResultsControllerProfile;
	}
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Profile" inManagedObjectContext:self.managedObjectContext];
    
	fetchRequest.entity = entity;
	fetchRequest.fetchLimit = 1;
	fetchRequest.sortDescriptors = @[];
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	self.fetchedResultsControllerProfile = aFetchedResultsController;
	_fetchedResultsControllerProfile.delegate = self;
    
	NSError *error;
	if (![_fetchedResultsControllerProfile performFetch:&error]) {
		// FIXME: Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
	return _fetchedResultsControllerProfile;
}

- (NSFetchedResultsController *)fetchedResultsControllerProgram
{
	if (_fetchedResultsControllerProgram != nil) {
		return _fetchedResultsControllerProgram;
	}
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Program" inManagedObjectContext:self.managedObjectContext];
    
	fetchRequest.entity = entity;
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES]];
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
	self.fetchedResultsControllerProgram = aFetchedResultsController;
	_fetchedResultsControllerProgram.delegate = self;
    
	NSError *error;
	if (![_fetchedResultsControllerProgram performFetch:&error]) {
		// FIXME: Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
    
	return _fetchedResultsControllerProgram;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger profile = 0;
	if ([[self.fetchedResultsControllerProfile fetchedObjects] count] > 0) profile++;
    
	return profile + [[self.fetchedResultsControllerProgram fetchedObjects] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) return 4;
	else {
		ETSProgram *program = self.fetchedResultsControllerProgram.fetchedObjects[section - 1];
		return [program.cresearch integerValue] > 0 ? 7 : 6;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) return NSLocalizedString(@"Informations personnelles", nil);
	else {
		ETSProgram *program = self.fetchedResultsControllerProgram.fetchedObjects[section - 1];
		return program.name;
	}
	return nil;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	if (indexPath.section == 0) {
		ETSProfile *profile = nil;
		if ([self.fetchedResultsControllerProfile.fetchedObjects count] > 0) profile = self.fetchedResultsControllerProfile.fetchedObjects[0];
        
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Prénom", nil);
			cell.detailTextLabel.text = profile.firstName;
		}
		else if (indexPath.row == 1) {
			cell.textLabel.text = NSLocalizedString(@"Nom de famille", nil);
			cell.detailTextLabel.text = profile.lastName;
		}
		else if (indexPath.row == 2) {
			cell.textLabel.text = NSLocalizedString(@"Code permanent", nil);
			cell.detailTextLabel.text = profile.permanentCode;
		}
		else if (indexPath.row == 3) {
			cell.textLabel.text = NSLocalizedString(@"Balance", nil);
			if ([self.formatter stringFromNumber:profile.balance]) {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ $", [self.formatter stringFromNumber:profile.balance]];
			}
			else {
				cell.detailTextLabel.text = @"—";
			}
        } else {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
        }
	}
	else {
		ETSProgram *program = nil;
		if ([self.fetchedResultsControllerProfile.fetchedObjects count] >= indexPath.section - 1) program = self.fetchedResultsControllerProgram.fetchedObjects[indexPath.section - 1];
		if (indexPath.row == 0) {
			cell.textLabel.text = NSLocalizedString(@"Statut", nil);
			cell.detailTextLabel.text = [program.status capitalizedString];
		}
		else if (indexPath.row == 1) {
			NSNumberFormatter *f = [NSNumberFormatter new];
			f.numberStyle = NSNumberFormatterDecimalStyle;
			f.maximumFractionDigits = 2;
			f.decimalSeparator = @",";
			cell.textLabel.text = NSLocalizedString(@"Moyenne cumulative", nil);
            if ([f stringFromNumber:program.results]) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/4,3", [f stringFromNumber:program.results]];
            } else {
                cell.detailTextLabel.text = @"—";
            }
		}
		else if (indexPath.row == 2) {
            if (program.start) {
                NSString *year = [program.start substringFromIndex:1];
                NSString *season = [program.start substringToIndex:1];
                NSString *name = @"";
                if ([season isEqualToString:@"H"]) name = @"Hiver";
                else if ([season isEqualToString:@"É"]) name = @"Été";
                else if ([season isEqualToString:@"A"]) name = @"Automne";

                cell.textLabel.text = NSLocalizedString(@"Début", nil);
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", name, year];
            } else {
                cell.detailTextLabel.text = @"—";
            }
		}
		else if (indexPath.row == 3) {
			cell.textLabel.text = NSLocalizedString(@"Fin", nil);
            
			if ([program.status isEqualToString:@"actif"]) {
				cell.detailTextLabel.text = NSLocalizedString(@"En cours", nil);
			}
            else if (!program.end) {
                cell.detailTextLabel.text = @"—";
            }
			else {
				NSString *year = [program.end substringFromIndex:1];
				NSString *season = [program.end substringToIndex:1];
				NSString *name = @"";
				if ([season isEqualToString:@"H"]) name = @"Hiver";
				else if ([season isEqualToString:@"É"]) name = @"Été";
				else if ([season isEqualToString:@"A"]) name = @"Automne";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", name, year];
			}
		}
		else if (indexPath.row == 4) {
			cell.textLabel.text = NSLocalizedString(@"Crédits réussis", nil);

			cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[program.ccompleted integerValue]];
		}
		else if (indexPath.row == 5) {
			cell.textLabel.text = NSLocalizedString(@"Crédits inscrits", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[program.cregistred integerValue]];
		}
		else if (indexPath.row == 6) {
			cell.textLabel.text = NSLocalizedString(@"Crédits de recherche", nil);
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[program.cresearch integerValue]];
		}
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo> )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	if (controller == self.fetchedResultsControllerProfile) {
		switch (type) {
			case NSFetchedResultsChangeInsert: {
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
				for (NSInteger i = 0; i < 4; i++) [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
			}
                
			case NSFetchedResultsChangeUpdate: {
				for (NSInteger i = 0; i < 4; i++) [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
				break;
			}
                
			case NSFetchedResultsChangeDelete: {
				for (NSInteger i = 0; i < 4; i++) [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
			}
                
			default:
				break;
		}
	}
    
	else if (controller == self.fetchedResultsControllerProgram) {
		switch (type) {
			case NSFetchedResultsChangeInsert: {
				NSInteger section = [[self.fetchedResultsControllerProgram fetchedObjects] indexOfObject:anObject] + 1;
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationAutomatic];
				NSInteger rows = ([((ETSProgram *)anObject).cresearch integerValue] > 0) ? 7 : 6;
				for (NSInteger i = 0; i < rows; i++) [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
			}
                
			case NSFetchedResultsChangeDelete: {
				// FIXME si un programme doit être supprimé de la base de données
				NSInteger rows = [self.tableView numberOfRowsInSection:indexPath.section + 1];
				for (NSInteger i = 0; i < rows; i++) [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:indexPath.section + 1]] withRowAnimation:UITableViewRowAnimationAutomatic];
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section + 1] withRowAnimation:UITableViewRowAnimationAutomatic];
				break;
			}
                
			case NSFetchedResultsChangeUpdate: {
				NSInteger section = [[self.fetchedResultsControllerProgram fetchedObjects] indexOfObject:anObject] + 1;
				NSInteger rows = ([((ETSProgram *)anObject).cresearch integerValue] > 0) ? 7 : 6;
				for (NSInteger i = 0; i < rows; i++) [self configureCell:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]] atIndexPath:[NSIndexPath indexPathForRow:i inSection:section]];
				break;
			}
                
			default:
				break;
		}
	}
}

- (void)synchronizationDidFinishLoading:(ETSSynchronization *)synchronization
{
	if (self.synchronizationDone >= 1) {
		[self.synchronization saveManagedObjectContext];
		[self.synchronizationProgram saveManagedObjectContext];
		self.synchronizationDone = 0;
		[self.refreshControl endRefreshing];
	}
	else {
		self.synchronizationDone++;
	}
}

- (void)controllerDidAuthenticate:(ETSAuthenticationViewController *)controller
{
    self.navigationItem.rightBarButtonItem.title = @"Déconnexion";
	self.synchronizationDone = 0;
	self.synchronization.request = [NSURLRequest requestForProfile];
	self.synchronizationProgram.request = [NSURLRequest requestForProgram];
    
	[super controllerDidAuthenticate:controller];
    
	NSError *error;
	[self.synchronizationProgram synchronize:&error];
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
	return [ETSAuthenticationViewController validateJSONResponse:response];
}

- (IBAction)logout:(id)sender
{
	self.isCleaning = YES;
	self.fetchedResultsControllerProgram.delegate = nil;
	self.fetchedResultsControllerProfile.delegate = nil;
	self.fetchedResultsControllerProgram = nil;
	self.fetchedResultsControllerProfile = nil;
    
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Profile" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Program" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Calendar" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Course" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Evaluation" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"MoodleCourse" inManagedObjectContext:self.managedObjectContext];
	[ETSCoreDataHelper deleteAllObjectsWithEntityName:@"MoodleElement" inManagedObjectContext:self.managedObjectContext];
	[ETSAuthenticationViewController resetKeychain];
    
	self.synchronizationProgram.request = nil;
	self.synchronization.request = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        ETSAuthenticationViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
        ac.delegate = self;
        [self.navigationController pushViewController:ac animated:YES];
    } else {
        [self.tableView reloadData];
        self.navigationItem.rightBarButtonItem.title = @"Connexion";
        UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardAuthenticationViewController];
        ETSAuthenticationViewController *authenticationController = (ETSAuthenticationViewController *)navigationController.topViewController;
        authenticationController.delegate = self;
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}

@end
