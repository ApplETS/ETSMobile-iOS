//
//  ETSBandwidthCircleChart.h
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright © 2015 ApplETS. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface ETSBandwidthCircleChart: UIView
@property (nonatomic) IBInspectable CGFloat used;
@property (nonatomic) IBInspectable CGFloat limit;
@property (nonatomic) IBInspectable CGFloat ideal;
@end
