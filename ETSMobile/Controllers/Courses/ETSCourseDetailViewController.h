//
//  ETSCourseDetailViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-06.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "ETSCoursesViewController_iPad.h"
#import "ETSCourse.h"

@interface ETSCourseDetailViewController : ETSTableViewController <ETSSynchronizationDelegate, NSFetchedResultsControllerDelegate, UISplitViewControllerDelegate, ETSCoursesViewControllerDelegate>
@property (nonatomic, strong) ETSCourse *course;
@end
