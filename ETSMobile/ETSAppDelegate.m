//
//  ETSAppDelegate.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-18.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSAppDelegate.h"

#import "MSDynamicsDrawerViewController.h"
#import "ETSMenuViewController.h"
#import "UIColor+Styles.h"
#import "NSURLRequest+API.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "ETSNewsViewController.h"
#import "ETSCoursesViewController_iPad.h"
#import "ETSCoursesViewController.h"
#import "ETSCourseDetailViewController.h"
#import "ETSRadioViewController.h"
#import "ETSWebViewViewController.h"
#import "ETSSecurityViewController.h"
#import "ETSDirectoryViewController.h"
#import "NotificationHelper.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <SupportKit/SupportKit.h>

#import <AWSCore/AWSCore.h>
#import <AWSSNS/AWSSNS.h>

#import "RKDropdownAlert.h"
#import "UIColor+Styles.h"

static NSString *const SNSPlatformApplicationArn = @"arn:aws:sns:us-east-1:834885693643:app/APNS/Applets-EtsMobile-iOS";


@implementation ETSAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor naviguationBarTintColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    self.dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.window.rootViewController;
    self.dynamicsDrawerViewController.screenEdgePanCancelsConflictingGestures = NO;
    self.dynamicsDrawerViewController.paneViewSlideOffAnimationEnabled = NO;
    self.dynamicsDrawerViewController.gravityMagnitude = 6;
    self.dynamicsDrawerViewController.bounceElasticity = 0;
    self.dynamicsDrawerViewController.bounceMagnitude = 0;
    self.dynamicsDrawerViewController.elasticity = 0;
    self.dynamicsDrawerViewController.paneDragRequiresScreenEdgePan = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone);
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler], [MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.dynamicsDrawerViewController.paneView.clipsToBounds = YES;
    }
    
    ETSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    menuViewController.managedObjectContext = self.managedObjectContext;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
        if (shortcutItem == nil) {
            menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
        [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
        }
        else {
            [self openViewController:menuViewController withString:shortcutItem.localizedTitle];
        }
    }
    else {
        menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
        [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    }

    // Transition to the first view controller
    [menuViewController transitionToViewController:ETSPaneViewControllerTypeCalendar];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.dynamicsDrawerViewController;
    [self.window makeKeyAndVisible];

    // Crashlytics
    [Fabric with:@[CrashlyticsKit]];
    
    // SupportKit
    NSString* apikey = (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SupportKitApiKey"];
    SKTSettings* settings = [SKTSettings settingsWithAppToken:apikey];
    settings.conversationStatusBarStyle = UIStatusBarStyleLightContent;
    settings.conversationAccentColor = [UIColor naviguationBarTintColor];
    settings.enableGestureHintOnFirstLaunch = NO;
    settings.enableAppWideGesture = NO;
    
    [SupportKit initWithSettings:settings];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        //register to receive notifications
        [application registerForRemoteNotifications];
    } else {
        // same as response to didFailToRegisterForRemoteNotificationsWithError
        NSDictionary* data = [NSDictionary dictionaryWithObject:@"" forKey:@"deviceToken"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationsRegistered" object:self userInfo:data];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *deviceTokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *userDataString = [NSString stringWithFormat:@"ENS\\%@",[ETSAuthenticationViewController usernameInKeychain]];
    
    NSLog(@"deviceTokenString: %@", deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSCreatePlatformEndpointInput *request = [AWSSNSCreatePlatformEndpointInput new];
    request.token = deviceTokenString;
    request.customUserData = userDataString;
    NSLog(@"%@", userDataString);
    request.platformApplicationArn = SNSPlatformApplicationArn;
    [[sns createPlatformEndpoint:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: %@",task.error);
        } else {
            AWSSNSCreateEndpointResponse *createEndPointResponse = task.result;
            NSLog(@"endpointArn: %@",createEndPointResponse);
            [[NSUserDefaults standardUserDefaults] setObject:createEndPointResponse.endpointArn forKey:@"endpointArn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
        
        return nil;
    }];
    
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register with error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        //opened from a push notification when the app was on background
        //here we need to redirect to user based on the kind of notifications he has received
        [self didOpenAppFromNotificationsWithUserInfo:userInfo];
        
        
    }
    else {
        [self showPushNotificationMessageReceivedWithUserInfo:userInfo];
    }
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

-(void)showPushNotificationMessageReceivedWithUserInfo:(NSDictionary *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HAS_PUSH_NOTIFICATION" object:nil];
    
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSString *applicationName = [userInfo objectForKey:@"NotificationApplicationNom"];
    NSString *alertMessage = [apsInfo objectForKey:@"alert"];
    NSString *notificationTitle = [NSString stringWithFormat:@"Notification de %@",
                                   applicationName];
    
    [RKDropdownAlert title:notificationTitle message:alertMessage backgroundColor:[UIColor naviguationBarTintColor] textColor:[UIColor whiteColor] time:5];
}

-(void)didOpenAppFromNotificationsWithUserInfo:(NSDictionary *)userInfo {
    
    NSString *typeNotification = [userInfo objectForKey:@"NotificationData_TypeNotification"];
    
    if ([typeNotification isEqualToString:@"SignetsLotsNouvellesNotes"] ||
        [typeNotification isEqualToString:@"SignetsLotsModificationNotes"] ||
        [typeNotification isEqualToString:@"SignetsModificationNote"] ||
        [typeNotification isEqualToString:@"SignetsCoteFinale"] ||
        [typeNotification isEqualToString:@"SignetsNouvelleNote"])
    
    {
        
        NSString *sigleName = [userInfo objectForKey:@"NotificationData_Sigle"];
        
        NSString *sessionDataString = [userInfo objectForKey:@"NotificationData_Session"];
        
        //NSMutableString *year = [sessionDataString substringWithRange:NSMakeRange(0, 4)];
        NSString *year = [sessionDataString substringToIndex:4];
        
        NSString *seasonString = [sessionDataString substringFromIndex:4];
        
        NSString *order = @"";
        
        NSString *courseId = @"";
        
        if ([seasonString isEqualToString:@"1"])      order = [NSString stringWithFormat:@"%@-%@", year, @"1"];
        else if ([seasonString isEqualToString:@"2"]) order = [NSString stringWithFormat:@"%@-%@", year, @"2"];
        else if ([seasonString isEqualToString:@"3"]) order = [NSString stringWithFormat:@"%@-%@", year, @"3"];
        else order = @"00000";
        
        courseId = [NSString stringWithFormat:@"%@%@", order, sigleName];
        
        NotificationHelper *myNotificationHelper = [NotificationHelper sharedInstance];
        myNotificationHelper.courseId = courseId;
        
        
        //This was a test to open the notes viewController.
        //This function needs to be changed to handle all kind of notifications received.
        
        ETSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
        menuViewController.managedObjectContext = self.managedObjectContext;
        
        menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
        [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
        
        [self openViewController:menuViewController withString:@"Notes"];
        
    }

}

#pragma mark - Quick Actions

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    
    ETSMenuViewController *menuViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"leftSideMenuViewController"];
    menuViewController.managedObjectContext = self.managedObjectContext;
    
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:menuViewController forDirection:MSDynamicsDrawerDirectionLeft];
    
    [self openViewController:menuViewController withString:shortcutItem.localizedTitle];
}

- (void)openViewController:(ETSMenuViewController *)menuViewController withString:(NSString *)shortcutTitle {
    
    if ([shortcutTitle isEqualToString: @"Horaire"]) {
        [menuViewController transitionToViewController:ETSPaneViewControllerTypeCalendar];
    } else if ([shortcutTitle isEqualToString:@"Notes"]) {
        [menuViewController transitionToViewController:ETSPaneViewControllerTypeCourses];
    } else if ([shortcutTitle isEqualToString:@"Moodle"]) {
        [menuViewController transitionToViewController:ETSPaneViewControllerTypeMoodle];
    } else if ([shortcutTitle isEqualToString:@"Bande Passante"]) {
        [menuViewController transitionToViewController:ETSPaneViewControllerTypeBandwidth];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ETSMobile24042015.sqlite"];
    
    //This options dictionnary is needed when migrating new core data database
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
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

+ (void)setUpPushNotifications
{
    // Sets up Mobile Push Notification
    UIMutableUserNotificationAction *readAction = [UIMutableUserNotificationAction new];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *deleteAction = [UIMutableUserNotificationAction new];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;
    
    UIMutableUserNotificationAction *ignoreAction = [UIMutableUserNotificationAction new];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeForeground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;
    
    UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    [messageCategory setActions:@[readAction, deleteAction, ignoreAction] forContext:UIUserNotificationActionContextDefault];
    
    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:@[messageCategory]]];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end
