//
//  ETSMenuViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-07-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kStoryboardNewsViewController;
extern NSString * const kStoryboardAuthenticationViewController;
extern NSString * const kStoryboardCoursesViewController;
extern NSString * const kStoryboardProfileViewController;
extern NSString * const kStoryboardMoodleViewController;
extern NSString * const kStoryboardCalendarViewController;
extern NSString * const kStoryboardDirectoryViewController;
extern NSString * const kStoryboardLibraryViewController;
extern NSString * const kStoryboardRadioViewController;
extern NSString * const kStoryboardSecurityViewController;
extern NSString * const kStoryboardBandwidthViewController;
extern NSString * const kStoryboardCommentViewController;
extern NSString * const kStoryboardAboutViewController;
extern NSString * const kStoryboardSponsorsViewController;

@interface ETSMenuViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
