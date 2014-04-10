//
//  ETSAppDelegate.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSAppDelegate.h"

#import "MFSideMenuContainerViewController.h"
#import "ETSMenuViewController.h"
#import "UIColor+Styles.h"
#import "NSURLRequest+API.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ETSNewsViewController.h"
#import "ETSCoursesViewController_iPad.h"
#import "ETSCourseDetailViewController.h"
#import "ETSRadioViewController.h"
#import "ETSWebViewViewController.h"
#import "ETSSecurityViewController.h"
#import "ETSDirectoryViewController.h"

@interface ETSAppDelegate ()
@property (nonatomic, strong) AVPlayerItem *playerItem;
@end

@implementation ETSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize radioPlayer = _radioPlayer;

- (void)startRadio
{
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL  URLWithString:@"http://radiopiranha.com:8000/radiopiranha.mp3"]];
    
    [self.playerItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:nil];

    _radioPlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    [_radioPlayer play];
}

- (void) observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object
                         change:(NSDictionary*)change context:(void*)context {
    
    if ([keyPath isEqualToString:@"timedMetadata"])
    {
        AVPlayerItem* playerItem = object;
        for (AVMetadataItem* metadata in playerItem.timedMetadata)
            if ([metadata.commonKey isEqualToString:@"title"]) self.currentRadioTitle = metadata.stringValue;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            UIViewController *controller = ((UINavigationController*)((MFSideMenuContainerViewController*)self.window.rootViewController).centerViewController).visibleViewController;
            if ([controller isKindOfClass:[ETSRadioViewController class]]) {
                controller.navigationItem.prompt = self.currentRadioTitle;
            }
        }
        else {
            UITabBarController *tbc =  (UITabBarController *)self.window.rootViewController;

            id svc = tbc.selectedViewController;
            
            if ([svc isKindOfClass:[UINavigationController class]] && [((UINavigationController *)svc).topViewController isKindOfClass:[ETSRadioViewController class]]) {
                ((UINavigationController *)svc).topViewController.navigationItem.prompt = self.currentRadioTitle;
            }
        }
    }
}


- (void)stopRadio
{
    self.currentRadioTitle = nil;
    [self.playerItem removeObserver:self forKeyPath:@"timedMetadata"];
    [_radioPlayer pause];
    _radioPlayer = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AVAudioSession sharedInstance] setActive: YES error: NULL];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor naviguationBarTintColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        [tabBarController.tabBar setSelectedImageTintColor:[UIColor whiteColor]];
        tabBarController.moreNavigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        for (id vc in tabBarController.viewControllers) {
            id viewController = nil;
            if ([vc isKindOfClass:[UINavigationController class]]) {
                viewController = ((UINavigationController *)vc).topViewController;
                
                if ([viewController isKindOfClass:[ETSWebViewViewController class]]) {
                    ((ETSWebViewViewController *)viewController).initialRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ets.mbiblio.ca"]];
                }
            }
            else if ([vc isKindOfClass:[UISplitViewController class]]) {
                UISplitViewController *splitViewController = (UISplitViewController *)vc;
                viewController = ((UINavigationController *)splitViewController.viewControllers[0]).topViewController;
                
                id detailsViewController = nil;
                if ([splitViewController.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
                    detailsViewController = ((UINavigationController *)splitViewController.viewControllers[1]).topViewController;
                }
                
                if ([viewController isKindOfClass:[ETSCoursesViewController_iPad class]]) {
                    splitViewController.delegate = detailsViewController;
                    ((ETSCoursesViewController_iPad *)viewController).delegate = detailsViewController;
                }
                else if ([viewController isKindOfClass:[ETSSecurityViewController class]]) {
                    splitViewController.delegate = detailsViewController;
                    ((ETSSecurityViewController *)viewController).delegate = detailsViewController;
                }
                else if ([viewController isKindOfClass:[ETSDirectoryViewController class]]) {
//                    splitViewController.delegate = detailsViewController;
                    ((ETSDirectoryViewController *)viewController).splitViewController = splitViewController;
                }
            }
            
            if ([viewController respondsToSelector:@selector(setManagedObjectContext:)])
                [viewController performSelector:@selector(setManagedObjectContext:) withObject:self.managedObjectContext];
            }
        
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
        MFSideMenuContainerViewController *container = (MFSideMenuContainerViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"navigationController"];

        ETSNewsViewController *controller = (ETSNewsViewController *)navigationController.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        ETSMenuViewController *leftSideMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
        leftSideMenuViewController.managedObjectContext = self.managedObjectContext;
        
        [container.shadow setEnabled:YES];
        [container.shadow setRadius:5.0f];
        [container.shadow setColor:[UIColor blackColor]];
        
        [container setLeftMenuViewController:leftSideMenuViewController];
        [container setCenterViewController:navigationController];
    
    }
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ETSMobile" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ETSMobile09042014.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
