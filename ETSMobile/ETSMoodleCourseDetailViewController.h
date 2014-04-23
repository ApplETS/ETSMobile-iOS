//
//  ETSMoodleCourseDetailViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-13.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"
#import "ETSMoodleCourse.h"

@interface ETSMoodleCourseDetailViewController : ETSTableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) ETSMoodleCourse *course;
@property (nonatomic, copy) NSString *token;

- (void)refreshView;

@end
