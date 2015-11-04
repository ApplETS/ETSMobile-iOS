//
//  ETSSponsorsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSponsorsViewController.h"

#import "Crashlytics.h"

@interface ETSSponsorsViewController ()
@property (nonatomic, strong) NSDictionary *sponsorsImages;
@property (nonatomic, strong) NSDictionary *sponsorsSizes;
@property (nonatomic, strong) NSDictionary *sponsorsSizesiPad;
@property (nonatomic, strong) NSDictionary *sponsorsURLs;
@end

@implementation ETSSponsorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sponsorsImages = @{
                            @(ETSSponsorETS)        : [UIImage imageNamed:@"LogoETS"],
                            @(ETSSponsorBell)       : [UIImage imageNamed:@"logoBell"],
                            @(ETSSponsorAEETS)      : [UIImage imageNamed:@"LogoAEETS"],
                            @(ETSSponsorFDETS)      : [UIImage imageNamed:@"logoFondDevETS"],
                            @(ETSSponsorGitHub)     : [UIImage imageNamed:@"logoGitHub"],
                            @(ETSSponsorBugSense)   : [UIImage imageNamed:@"logoBugsense"],
                            @(ETSSponsorAtlassian)  : [UIImage imageNamed:@"logoAtlassian"],
                            };
    
    self.sponsorsSizes = @{
                            @(ETSSponsorETS)        : [NSValue valueWithCGSize:CGSizeMake(250, 100)],
                            @(ETSSponsorBell)       : [NSValue valueWithCGSize:CGSizeMake(250, 80)],
                            @(ETSSponsorAEETS)      : [NSValue valueWithCGSize:CGSizeMake(150, 70)],
                            @(ETSSponsorFDETS)      : [NSValue valueWithCGSize:CGSizeMake(150, 70)],
                            @(ETSSponsorGitHub)     : [NSValue valueWithCGSize:CGSizeMake(150, 85)],
                            @(ETSSponsorBugSense)   : [NSValue valueWithCGSize:CGSizeMake(150, 70)],
                            @(ETSSponsorAtlassian)  : [NSValue valueWithCGSize:CGSizeMake(320, 40)],
                            };
    
    self.sponsorsSizesiPad = @{
                           @(ETSSponsorETS)        : [NSValue valueWithCGSize:CGSizeMake(850, 200)],
                           @(ETSSponsorBell)       : [NSValue valueWithCGSize:CGSizeMake(850, 140)],
                           @(ETSSponsorAEETS)      : [NSValue valueWithCGSize:CGSizeMake(350, 100)],
                           @(ETSSponsorFDETS)      : [NSValue valueWithCGSize:CGSizeMake(350, 100)],
                           @(ETSSponsorGitHub)     : [NSValue valueWithCGSize:CGSizeMake(350, 120)],
                           @(ETSSponsorBugSense)   : [NSValue valueWithCGSize:CGSizeMake(350, 90)],
                           @(ETSSponsorAtlassian)  : [NSValue valueWithCGSize:CGSizeMake(320, 80)],
                           };
    
    self.sponsorsURLs = @{
                           @(ETSSponsorETS)        : [NSURL URLWithString:@"http://m.etsmtl.ca"],
                           @(ETSSponsorBell)       : [NSURL URLWithString:@"http://www.bell.ca"],
                           @(ETSSponsorAEETS)      : [NSURL URLWithString:@"http://aeets.com"],
                           @(ETSSponsorFDETS)      : [NSURL URLWithString:@"http://fdets.etsmtl.ca"],
                           @(ETSSponsorGitHub)     : [NSURL URLWithString:@"https://github.com"],
                           @(ETSSponsorBugSense)   : [NSURL URLWithString:@"https://www.bugsense.com"],
                           @(ETSSponsorAtlassian)  : [NSURL URLWithString:@"https://www.atlassian.com"],
                           };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [Answers logContentViewWithName:@"Sponsors"
                        contentType:@"Sponsors"
                          contentId:@"ETS-Sponsors"
                   customAttributes:@{}];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return [self.sponsorsSizes[@(indexPath.row)] CGSizeValue];
    } else {
        return [self.sponsorsSizesiPad[@(indexPath.row)] CGSizeValue];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SponsorIdentifier" forIndexPath:indexPath];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.sponsorsImages[@(indexPath.row)]];
    imageView.frame = CGRectIntegral(CGRectMake(0, 0, cell.bounds.size.width-5, cell.bounds.size.height-5));
    imageView.center = CGPointMake(cell.bounds.size.width/2, cell.bounds.size.height/2);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cell addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] openURL:self.sponsorsURLs[@(indexPath.row)]];
}

@end
