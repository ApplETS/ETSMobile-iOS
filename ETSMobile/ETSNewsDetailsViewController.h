//
//  ETSNewsDetailsViewController.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-17.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETSNews.h"

@interface ETSNewsDetailsViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) ETSNews *news;

@end
