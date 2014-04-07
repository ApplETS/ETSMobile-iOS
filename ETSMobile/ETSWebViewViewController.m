//
//  ETSWebViewViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-20.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSWebViewViewController.h"

@interface ETSWebViewViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@end

@implementation ETSWebViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [((UIWebView *)self.view).scrollView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    if (self.initialRequest) {
        [((UIWebView *)self.view) loadRequest:self.initialRequest];
        self.stopBarButtonItem.enabled = YES;
        self.refreshBarButtonItem.enabled = NO;
    }
}

#pragma UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.stopBarButtonItem.enabled = YES;
    self.refreshBarButtonItem.enabled = NO;
    self.nextBarButtonItem.enabled = ((UIWebView *)self.view).canGoForward;
    self.backBarButtonItem.enabled = ((UIWebView *)self.view).canGoBack;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.stopBarButtonItem.enabled = NO;
    self.refreshBarButtonItem.enabled = YES;
    self.nextBarButtonItem.enabled = ((UIWebView *)self.view).canGoForward;
    self.backBarButtonItem.enabled = ((UIWebView *)self.view).canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.stopBarButtonItem.enabled = NO;
    self.refreshBarButtonItem.enabled = YES;
    self.nextBarButtonItem.enabled = ((UIWebView *)self.view).canGoForward;
    self.backBarButtonItem.enabled = ((UIWebView *)self.view).canGoBack;
}

@end
