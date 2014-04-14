//
//  ETSRadioCell.h
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-05.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETSEvent;

@interface ETSRadioCell : UICollectionViewCell

@property (nonatomic, weak) ETSEvent *event;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *location;

@end
