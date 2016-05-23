//
//  ETSSecurityDetailViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-04-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityDetailViewController.h"
#import "ETSSecurityProcedureViewController.h"

#import <Crashlytics/Crashlytics.h>

@interface ETSSecurityDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIBarButtonItem *securityBarButtonItem;
@end

@implementation ETSSecurityDetailViewController

- (void)updateProcedure
{
    if (!self.summary) self.summary = @"";
    
    [self.textView setTextContainerInset:UIEdgeInsetsMake(12, 0, 12, 12)];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSString *fontSize = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @"16pt" : @"11pt";
    
    NSString *content = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html><head><style type=\"text/css\">html {font-family:\"IowanOldStyle-Roman\";font-size:%@;text-align:left;line-height:110%%; word-break: hyphenate; -webkit-hyphens: auto;}li {margin: 10px 0;}</style><meta charset=\"UTF-8\"></head><body>%@</body></html>", fontSize, self.summary];
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
    
    self.textView.attributedText = [html mutableCopy];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateProcedure];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Security Details"
                        contentType:@"Security"
                          contentId:@"ETS-Security-Details"
                   customAttributes:@{}];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.securityBarButtonItem.target performSelector:self.securityBarButtonItem.action withObject:self.securityBarButtonItem];
#pragma clang diagnostic pop
}

- (IBAction)emergencyCall:(id)sender
{
    NSString *phoneNumber = @"telprompt://5143968900";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!self.file || self.file.length <= 0) return;
    
    if ([[segue destinationViewController] isKindOfClass:[ETSSecurityProcedureViewController class]]) {
        ETSSecurityProcedureViewController *viewController = [segue destinationViewController];
        
        viewController.file = self.file;
        viewController.title = self.title;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Sommaire" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.securityBarButtonItem = barButtonItem;
    barButtonItem.title = NSLocalizedString(@"Procédures", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)securityViewController:(ETSSecurityViewController *)controller didSelectProcedureWithTitle:(NSString *)title summary:(NSString *)summary file:(NSString *)file
{
    self.title = title;
    self.summary = summary;
    self.file = file;
    
    [self updateProcedure];
}

@end
