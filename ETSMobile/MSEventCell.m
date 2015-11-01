//
//  MSEventCell.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSEventCell.h"
#import "ETSCalendar.h"
#import "NSDate+Timezone.h"

@interface MSEventCell ()

@property (nonatomic, strong) UIView *borderView;

@end

@implementation MSEventCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.0;
        
        self.borderView = [UIView new];
        [self.contentView addSubview:self.borderView];
        
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.title];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 0;
        self.location.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.location];
        
        
        
        [self updateColors];
        
        self.borderView.translatesAutoresizingMaskIntoConstraints = NO;
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.location.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addConstraints:@[
                               
                               //view1 constraints
                               [NSLayoutConstraint constraintWithItem:self.borderView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.borderView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:2],
                               [NSLayoutConstraint constraintWithItem:self.borderView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:0],
                               [NSLayoutConstraint constraintWithItem:self.borderView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:0],
                               
                               [NSLayoutConstraint constraintWithItem:self.title
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:2],
                               [NSLayoutConstraint constraintWithItem:self.title
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:6],
                               [NSLayoutConstraint constraintWithItem:self.title
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-4],
                               
                               [NSLayoutConstraint constraintWithItem:self.location
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self.title
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:2],
                               [NSLayoutConstraint constraintWithItem:self.location
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:6],
                               [NSLayoutConstraint constraintWithItem:self.location
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-4],
                               [NSLayoutConstraint constraintWithItem:self.location
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationLessThanOrEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0
                                                             constant:-1],
                               ]
         ];
    }
    return self;
}

#pragma mark - UICollectionViewCell

- (void)setSelected:(BOOL)selected
{
    if (selected && (self.selected != selected)) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.025, 1.025);
            self.layer.shadowOpacity = 0.2;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformIdentity;
            }];
        }];
    } else if (selected) {
        self.layer.shadowOpacity = 0.2;
    } else {
        self.layer.shadowOpacity = 0.0;
    }
    [super setSelected:selected]; // Must be here for animation to fire
    [self updateColors];
}

#pragma mark - MSEventCell

- (void)setEvent:(ETSCalendar *)event
{
    _event = event;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *utcStartDate = [event.start toUTCTime];
    NSDate *utcEndDate = [event.end toUTCTime];
    NSString *timeStart = [dateFormatter stringFromDate:utcStartDate];
    NSString *timeEnd = [dateFormatter stringFromDate:utcEndDate];
    NSString *title = [NSString stringWithFormat:@"%@\n%@", event.title, event.course];
    self.title.attributedText = [[NSAttributedString alloc] initWithString:title attributes:[self titleAttributesHighlighted:self.selected]];

    NSString *details = [NSString stringWithFormat:@"%@\n%@\n%@ - %@", event.summary, event.room, timeStart, timeEnd];
    self.location.attributedText = [[NSAttributedString alloc] initWithString:details attributes:[self subtitleAttributesHighlighted:self.selected]];;
}

- (void)updateColors
{
    self.contentView.backgroundColor = [self backgroundColorHighlighted:self.selected];
    self.borderView.backgroundColor = [self borderColor];
    self.title.textColor = [self textColorHighlighted:self.selected];
    self.location.textColor = [self textColorHighlighted:self.selected];
}

- (NSDictionary *)titleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    return @{
        NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0],
        NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

- (NSDictionary *)subtitleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
        NSFontAttributeName : [UIFont systemFontOfSize:12.0],
        NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

- (UIColor *)backgroundColorHighlighted:(BOOL)selected
{
    return selected ? [UIColor colorWithRed:53/255.0f green:177/255.0f blue:241/255.0f alpha:1] : [UIColor colorWithRed:53/255.0f green:177/255.0f blue:241/255.0f alpha:0.2f];
}

- (UIColor *)textColorHighlighted:(BOOL)selected
{
    return selected ? [UIColor whiteColor] : [UIColor colorWithRed:33/255.0f green:114/255.0f blue:156/255.0f alpha:1.0f];
}

- (UIColor *)borderColor
{
    return [[self backgroundColorHighlighted:NO] colorWithAlphaComponent:1.0];
}

@end
