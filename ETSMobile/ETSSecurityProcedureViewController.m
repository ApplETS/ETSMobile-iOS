//
//  ETSSecurityProcedureViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-08.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityProcedureViewController.h"

#import <Crashlytics/Crashlytics.h>

@interface ETSSecurityProcedureViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ETSSecurityProcedureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.scalesPageToFit = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.file ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Security Procedure"
                        contentType:@"Security"
                          contentId:@"ETS-Security-Procedure"
                   customAttributes:@{}];
}


@end
