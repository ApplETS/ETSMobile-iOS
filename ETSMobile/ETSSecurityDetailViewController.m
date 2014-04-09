//
//  ETSSecurityDetailViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-04-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityDetailViewController.h"
#import "ETSSecurityProcedureViewController.h"

@interface ETSSecurityDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation ETSSecurityDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textView setTextContainerInset:UIEdgeInsetsMake(12, 0, 12, 12)];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSString *content = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html><head><style type=\"text/css\">html {font-family:\"IowanOldStyle-Roman\";font-size:11pt;text-align:left;line-height:110%%; word-break: hyphenate; -webkit-hyphens: auto;}li {margin: 10px 0;}</style><meta charset=\"UTF-8\"></head><body>%@</body></html>", self.summary];
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
    
    self.textView.attributedText = [html mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (IBAction)emergencyCall:(id)sender
{
    NSString *phoneNumber = @"telprompt://5143968900";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[ETSSecurityProcedureViewController class]]) {
        ETSSecurityProcedureViewController *viewController = [segue destinationViewController];
        
        viewController.file = self.file;
        viewController.title = self.title;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Sommaire" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
    }
}

@end
