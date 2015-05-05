//
//  ETSSponsorsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSponsorsViewController.h"

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
    
<<<<<<< HEAD
<<<<<<< HEAD
=======
    #ifdef __USE_BUGSENSE
    [[Mint sharedInstance] leaveBreadcrumb:@"SPONSORS_VIEWCONTROLLER"];
    #endif

    
>>>>>>> Retrait de TestFlight.
=======
>>>>>>> Mise à jour de 2.0.3 vers 2.1
    self.sponsorsImages = @{
                            @(ETSSponsorETS)        : [UIImage imageNamed:@"LogoETS"],
                            @(ETSSponsorBell)       : [UIImage imageNamed:@"logoBell"],
                            @(ETSSponsorAEETS)      : [UIImage imageNamed:@"LogoAEETS"],
                            @(ETSSponsorFDETS)      : [UIImage imageNamed:@"logoFondDevETS"],
                            };
    
    self.sponsorsSizes = @{
                            @(ETSSponsorETS)        : [NSValue valueWithCGSize:CGSizeMake(250, 100)],
                            @(ETSSponsorBell)       : [NSValue valueWithCGSize:CGSizeMake(250, 80)],
                            @(ETSSponsorAEETS)      : [NSValue valueWithCGSize:CGSizeMake(150, 70)],
                            @(ETSSponsorFDETS)      : [NSValue valueWithCGSize:CGSizeMake(150, 70)],                            };
    
    self.sponsorsSizesiPad = @{
                           @(ETSSponsorETS)        : [NSValue valueWithCGSize:CGSizeMake(850, 200)],
                           @(ETSSponsorBell)       : [NSValue valueWithCGSize:CGSizeMake(850, 140)],
                           @(ETSSponsorAEETS)      : [NSValue valueWithCGSize:CGSizeMake(350, 100)],
                           @(ETSSponsorFDETS)      : [NSValue valueWithCGSize:CGSizeMake(350, 100)],
                           };
    
    self.sponsorsURLs = @{
                           @(ETSSponsorETS)        : [NSURL URLWithString:@"http://m.etsmtl.ca"],
                           @(ETSSponsorBell)       : [NSURL URLWithString:@"http://www.bell.ca"],
                           @(ETSSponsorAEETS)      : [NSURL URLWithString:@"http://aeets.com"],
                           @(ETSSponsorFDETS)      : [NSURL URLWithString:@"http://fdets.etsmtl.ca"],
                           };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
