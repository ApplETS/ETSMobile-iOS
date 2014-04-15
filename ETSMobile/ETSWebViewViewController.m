//
//  ETSWebViewViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-20.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSWebViewViewController.h"
#import "UIViewController+ScrollingNavbar.h"
#import "MFSideMenu.h"

@interface ETSWebViewViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@end

@implementation ETSWebViewViewController

- (IBAction)panLeftMenu:(id)sender
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.toolbar setTranslucent:NO];
    [self followScrollView:self.webView];
	self.webView.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    if (self.initialRequest) {
        [self.webView loadRequest:self.initialRequest];
        self.stopBarButtonItem.enabled = YES;
        self.refreshBarButtonItem.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self showNavBarAnimated:NO];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
	[self showNavbar];	
	return YES;
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
