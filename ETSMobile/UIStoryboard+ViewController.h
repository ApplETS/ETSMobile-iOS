//
//  UIStoryboard+ViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-25.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIStoryboard (ViewController)
- (id)instantiateNewsViewController;
- (id)instantiateAuthenticationViewController;
- (id)instantiateCoursesViewController;
- (id)instantiateProfileViewController;
- (id)instantiateDirectoryViewController;
- (id)instantiateLibraryViewController;
- (id)instantiateRadioViewController;
- (id)instantiateBandwidthViewController;
@end
