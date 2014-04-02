//
//  MSEventCell.h
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ETSCalendar;

@interface MSEventCell : UICollectionViewCell

@property (nonatomic, weak) ETSCalendar *event;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *location;

@end
