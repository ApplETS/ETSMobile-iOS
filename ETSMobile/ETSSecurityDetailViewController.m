//
//  ETSSecurityDetailViewController.m
//  ETSMobile
//
//  Created by Maxime Lapointe on 2014-04-02.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityDetailViewController.h"

@interface ETSSecurityDetailViewController ()
@property (nonatomic, weak) IBOutlet UITextView *textView;
@end

@implementation ETSSecurityDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textView setTextContainerInset:UIEdgeInsetsMake(12, 0, 12, 12)];
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSString *content = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html><head><style type=\"text/css\">html {font-family:\"IowanOldStyle-Roman\";font-size:11pt;text-align:left;line-height:110%%; word-break: hyphenate; -webkit-hyphens: auto;}</style><meta charset=\"UTF-8\"></head><body>%@</body></html>", self.summary];
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
    
    self.textView.attributedText = [html mutableCopy];
}

@end
