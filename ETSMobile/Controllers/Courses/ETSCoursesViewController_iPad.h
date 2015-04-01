//
//  ETSCoursesViewController_iPad.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-09.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "ETSCourse.h"

@protocol ETSCoursesViewControllerDelegate;

@interface ETSCoursesViewController_iPad : ETSTableViewController <ETSSynchronizationDelegate>

@property (nonatomic, weak) id<ETSCoursesViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UISplitViewController *splitViewController;

@end

@protocol ETSCoursesViewControllerDelegate <NSObject>
- (void)coursesViewController:(ETSCoursesViewController_iPad *)controller didSelectCourse:(ETSCourse *)course managedObjectContext:(NSManagedObjectContext*)context;
@end