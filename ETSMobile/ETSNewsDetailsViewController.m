//
//  ETSNewsDetailsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-17.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsDetailsViewController.h"

@interface ETSNewsDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)shareNews:(id)sender;
- (IBAction)openNews:(id)sender;
@end

@implementation ETSNewsDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [TestFlight passCheckpoint:@"STORY_VIEWCONTROLLER"];
    
    [self.textView setTextContainerInset:UIEdgeInsetsMake(12, 12, 12, 12)];
    
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSError *error = nil;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSMutableParagraphStyle *hyphenation = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [hyphenation setHyphenationFactor:1.0];
    
    attributes[NSParagraphStyleAttributeName] = hyphenation;
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[self.news.summary componentsSeparatedByString:@"\n"]];
    
    NSString *base = @"";
    // Petit hack pour enlever lien de partage facebook en début d'article.
    if ([self.news.source isEqualToString:@"etsmtl.ca"]) {
        [lines removeObjectsInRange:NSMakeRange(0, 2)];
        lines[0] = [lines[0] stringByReplacingOccurrencesOfString:@"<br><br>" withString:@""];
    }
    
    // Petit hack pour que les liens des articles facebook fonctionnent
    else if ([self.news.source isEqualToString:@"facebook.com"]) {
        base = @"<base href=\"http://www.facebook.com\"/>";
    }
    
    NSString *content = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html><head>%@<style type=\"text/css\">html {font-family:\"IowanOldStyle-Roman\";font-size:14pt;text-align:justify;line-height:130%%; word-break: hyphenate; -webkit-hyphens: auto;} h1 {font-size:16pt; text-align:center;} img { text-align:center;}</style><meta charset=\"UTF-8\"></head><body><h1>%@</h1>%@</body></html>", base, self.news.title, [lines componentsJoinedByString:@""]];
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    self.textView.attributedText = [html mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (IBAction)shareNews:(id)sender
{
    NSArray *activityItems = @[self.news.title, [NSURL URLWithString:self.news.link]];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)openNews:(id)sender
{
    if ([self.news.link rangeOfString:@"facebook.com"].location != NSNotFound && [self.news.link rangeOfString:@"/posts/"].location != NSNotFound) {
        
        NSArray *components = [self.news.link componentsSeparatedByString:@"/"];
        NSURL *fbURL = [NSURL URLWithString:[NSString stringWithFormat:@"fb://post/%@", components.lastObject]];
        if ([[UIApplication sharedApplication] canOpenURL:fbURL]) {
            [[UIApplication sharedApplication] openURL:fbURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.news.link]];
        }
    } else {
        [NSURL URLWithString:self.news.link];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    return YES;
}

@end
