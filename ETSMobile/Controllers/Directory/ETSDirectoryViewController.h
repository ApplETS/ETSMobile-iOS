//
//  ETSDirectoryViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-14.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSTableViewController.h"

@interface ETSDirectoryViewController : ETSTableViewController <ETSSynchronizationDelegate, UISearchDisplayDelegate, UISearchBarDelegate, UISplitViewControllerDelegate>

@property (nonatomic, weak) UISplitViewController *splitViewController;

@end
