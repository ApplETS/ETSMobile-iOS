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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textView setTextContainerInset:UIEdgeInsetsMake(12, 12, 12, 12)];
    
    NSLog(@"%@", self.news.summary);
    NSDictionary *options = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType};
    
    NSError *error = nil;
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSMutableParagraphStyle *hyphenation = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [hyphenation setHyphenationFactor:1.0];
    
    attributes[NSParagraphStyleAttributeName]=hyphenation;
    
    NSMutableArray *lines = [NSMutableArray arrayWithArray:[self.news.summary componentsSeparatedByString:@"\n"]];
    
    if ([self.news.source isEqualToString:@"etsmtl.ca"]) {
        [lines removeObjectsInRange:NSMakeRange(0, 2)];
        lines[0] = [lines[0] stringByReplacingOccurrencesOfString:@"<br><br>" withString:@""];
    }
    
    NSLog(@"%@", self.news.link);
    
    //FIXME: on doit ajouter <base href=\"http://www.facebook.com/\"/> pour que les liens fonctionnent.
    NSString *content = [NSString stringWithFormat:@"<!DOCTYPE html>\n<html><head><style type=\"text/css\">html {font-family:\"IowanOldStyle-Roman\";font-size:14pt;text-align:justify;line-height:130%%; word-break: hyphenate; -webkit-hyphens: auto;} h1 {font-size:16pt; text-align:center;} img { text-align:center;}</style></head><body><h1>%@</h1>%@</body></html>", self.news.title, [lines componentsJoinedByString:@""]];
    
    NSAttributedString *html = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:&error];
    
    //    NSMutableDictionary *attributes2 = [[NSMutableDictionary alloc] init];
    //    NSMutableParagraphStyle *hyphenation = [[NSParagraphStyle [html para]] mutableCopy];
    //    [hyphenation setHyphenationFactor:1.0];
    
    
    NSMutableAttributedString *res = [html mutableCopy];
    /*[res beginEditing];
     [res enumerateAttribute:NSFontAttributeName
     inRange:NSMakeRange(0, res.length)
     options:0
     usingBlock:^(id value, NSRange range, BOOL *stop) {
     if (value) {
     
     UIFont *newFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
     [res addAttribute:NSFontAttributeName value:newFont range:range];
     }
     }];
     [res endEditing];*/
    
    
    
    self.textView.attributedText = res;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSLog(@"URL:%@", URL);
    return YES;
}

@end
