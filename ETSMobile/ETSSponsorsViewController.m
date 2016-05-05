//
//  ETSSponsorsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-04-06.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSSponsorsViewController.h"
#import "ETSSynchronization.h"
#import "NSURLRequest+API.h"
#import "ETSSponsors.h"
#import "ETSCoreDataHelper.h"
#import "UIImageView+WebCache.h"
#import "ETSCollectionViewCell.h"
#import "ETSCoreDataHelper.h"

#import "Crashlytics.h"

@interface ETSSponsorsViewController ()

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;

@end

@implementation ETSSponsorsViewController

@synthesize fetchedResultsController = _fetchedResultsController;


- (void)updateSponsors
{
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Sponsors" inManagedObjectContext:self.managedObjectContext];
    
    self.synchronization.request = [NSURLRequest requestForSponsors];
    
    NSError *error;
    [self.synchronization synchronize:&error];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cellIdentifier = @"SponsorCell";
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    
    synchronization.entityName = @"Sponsors";
    synchronization.compareKey = @"name";
    synchronization.objectsKeyPath = @"partner";
    synchronization.appletsServer = YES;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    self.title = @"Nos partenaires";
    
    
    self.synchronization.request = [NSURLRequest requestForSponsors];
    
    
    //self.sponsorsArray = _fetchedResultsController.fetchedObjects;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*[Answers logContentViewWithName:@"Sponsors"
                        contentType:@"Sponsors"
                          contentId:@"ETS-Sponsors"
                   customAttributes:@{}];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];*/
    [self.navigationController setToolbarHidden:NO animated:animated];
    
    
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sponsors" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    fetchRequest.fetchBatchSize = 24;
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = aFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

- (ETSSynchronizationResponse)synchronization:(ETSSynchronization *)synchronization validateJSONResponse:(NSDictionary *)response
{
    return ETSSynchronizationResponseValid;
}


- (void)synchronization:(ETSSynchronization *)synchronization didReceiveResponse:(ETSSynchronizationResponse)response
{
    NSLog(@"TODO: VALIDATION");
}
/*- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSSponsors *sponsor = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [[cell subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *imageView = (UIImageView *) [cell viewWithTag:100];
    
    //[imageView sd_setImageWithURL:[NSURL URLWithString:sponsor.image_url]];

    NSLog(sponsor.image_url);
    
    
    [imageView setImage:[UIImage imageNamed:@"ico_partners"]];
    
    [cell addSubview:imageView];
    
}*/

- (void)synchronization:(ETSSynchronization *)synchronization didReceiveObject:(NSDictionary *)object forManagedObject:(NSManagedObject *)managedObject
{
    if (![managedObject isKindOfClass:[ETSSponsors class]])
        return;
}

/*- (void)configureCell:(ETSCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ETSSponsors * sponsors = [self.fetchedResultsController objectAtIndexPath:indexPath];
}*/

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Sponsors" inManagedObjectContext:self.managedObjectContext];
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    
    NSArray *sponsors = (NSArray *)objects;
    
    for (NSDictionary * sponsor in sponsors) {
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        
        [entry setValue:[sponsor valueForKey:@"image_url"] forKey:@"image_url"];
        
        [entries addObject:entry];
    }
    
    return entries;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

-(ETSCollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ETSCollectionViewCell * sponsorCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SponsorCell" forIndexPath:indexPath];
    
  
    //sponsorCell.sponsorImageView.image = [UIImage imageNamed:@"ico_partners"];
    
    return sponsorCell;
    
}

@end
