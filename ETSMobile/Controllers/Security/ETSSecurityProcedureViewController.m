//
//  ETSSecurityProcedureViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-08.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSecurityProcedureViewController.h"

@interface ETSSecurityProcedureViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ETSSecurityProcedureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
<<<<<<< HEAD
<<<<<<< HEAD
=======
    #ifdef __USE_BUGSENSE
    [[Mint sharedInstance] leaveBreadcrumb:@"SECURITY_PROCEDURE_VIEWCONTROLLER"];
    #endif
    
>>>>>>> Retrait de TestFlight.
=======
>>>>>>> Mise à jour de 2.0.3 vers 2.1
    self.webView.scalesPageToFit = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.file ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webView loadRequest:request];
}


@end
