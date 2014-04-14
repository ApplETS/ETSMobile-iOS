//
//  UIStoryboard+ViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-09-25.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "UIStoryboard+ViewController.h"

@implementation UIStoryboard (ViewController)

- (id)instantiateNewsViewController
{
    return [self instantiateViewControllerWithIdentifier:@"NewsViewController"];
}

- (id)instantiateAuthenticationViewController
{
    return [self instantiateViewControllerWithIdentifier:@"AuthenticationViewController"];
}

- (id)instantiateCoursesViewController
{
    return [self instantiateViewControllerWithIdentifier:@"CoursesViewController"];
}

- (id)instantiateProfileViewController
{
    return [self instantiateViewControllerWithIdentifier:@"ProfileViewController"];
}

- (id)instantiateMoodleViewController
{
    return [self instantiateViewControllerWithIdentifier:@"MoodleViewController"];
}

- (id)instantiateCalendarViewController
{
    return [self instantiateViewControllerWithIdentifier:@"CalendarViewController"];
}

- (id)instantiateDirectoryViewController
{
    return [self instantiateViewControllerWithIdentifier:@"DirectoryViewController"];
}

- (id)instantiateLibraryViewController
{
    return [self instantiateViewControllerWithIdentifier:@"WebViewController"];
}

- (id)instantiateRadioViewController
{
    return [self instantiateViewControllerWithIdentifier:@"RadioViewController"];
}

- (id)instantiateSecurityViewController
{
    return [self instantiateViewControllerWithIdentifier:@"SecurityViewController"];
}

- (id)instantiateBandwidthViewController
{
    return [self instantiateViewControllerWithIdentifier:@"BandwidthViewController"];
}

- (id)instantiateCommentViewController
{
    return [self instantiateViewControllerWithIdentifier:@"CommentViewController"];
}

- (id)instantiateAboutViewController
{
    return [self instantiateViewControllerWithIdentifier:@"AboutViewController"];
}

- (id)instantiateSponsorsViewController
{
    return [self instantiateViewControllerWithIdentifier:@"SponsorsViewController"];
}

@end
