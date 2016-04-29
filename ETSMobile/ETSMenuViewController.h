//
//  ETSMenuViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-07-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerStyler.h"

extern NSString * const kStoryboardAuthenticationViewController;

typedef NS_ENUM(NSUInteger, ETSPaneViewControllerType) {
    ETSPaneViewControllerTypeCalendar,
    ETSPaneViewControllerTypeCourses,
    ETSPaneViewControllerTypeProfile,
    ETSPaneViewControllerTypeMoodle,
    ETSPaneViewControllerTypeBandwidth,
    ETSPaneViewControllerTypeNews,
    ETSPaneViewControllerTypeDirectory,
    ETSPaneViewControllerTypeLibrary,
    ETSPaneViewControllerTypeMonets,
    ETSPaneViewControllerTypeRadio,
    ETSPaneViewControllerTypeSecurity,
    ETSPaneViewControllerTypeComment,
    ETSPaneViewControllerTypeAbout,
    ETSPaneViewControllerTypeSponsors
};

@interface ETSMenuViewController : UITableViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) ETSPaneViewControllerType paneViewControllerType;
@property (nonatomic, weak)   MSDynamicsDrawerViewController *dynamicsDrawerViewController;

- (void)transitionToViewController:(ETSPaneViewControllerType)paneViewControllerType;

@end
