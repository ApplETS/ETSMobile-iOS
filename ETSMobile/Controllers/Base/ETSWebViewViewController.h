//
//  ETSWebViewViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-20.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETSWebViewViewController : UIViewController <UISplitViewControllerDelegate>
@property (nonatomic, strong) NSURLRequest *request;
-(void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
@end
