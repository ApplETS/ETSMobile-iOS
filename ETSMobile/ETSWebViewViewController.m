//
//  ETSWebViewViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-20.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "ETSWebViewViewController.h"
#import "UIViewController+ScrollingNavbar.h"

@interface ETSWebViewViewController () <UIScrollViewDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBarButtonItem;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) UIBarButtonItem *masterBarButtonItem;
@end

@implementation ETSWebViewViewController

@synthesize request = _request;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.toolbar setTranslucent:NO];
    [self followScrollView:self.webView];
	self.webView.scrollView.delegate = self;
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    if (self.request) {
        [self.webView loadRequest:self.request];
        self.stopBarButtonItem.enabled = YES;
        self.refreshBarButtonItem.enabled = NO;
    }
}

- (void)setRequest:(NSURLRequest *)request
{
    _request = request;
    
    if (request) {
        [self.webView loadRequest:self.request];
        self.stopBarButtonItem.enabled = YES;
        self.refreshBarButtonItem.enabled = NO;
    }
}

-(void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [self.webView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
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
    self.nextBarButtonItem.enabled = self.webView.canGoForward;
    self.backBarButtonItem.enabled = self.webView.canGoBack;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.stopBarButtonItem.enabled = NO;
    self.refreshBarButtonItem.enabled = YES;
    self.nextBarButtonItem.enabled = self.webView.canGoForward;
    self.backBarButtonItem.enabled = self.webView.canGoBack;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.stopBarButtonItem.enabled = NO;
    self.refreshBarButtonItem.enabled = YES;
    self.nextBarButtonItem.enabled = self.webView.canGoForward;
    self.backBarButtonItem.enabled = self.webView.canGoBack;
}

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    self.masterBarButtonItem = barButtonItem;
    barButtonItem.title = NSLocalizedString(@"Cours", nil);
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
