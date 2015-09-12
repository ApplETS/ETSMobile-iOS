//
//  ETSBandwidthViewController.m
//  ETSMobile
//
//  Created by Thomas Durand on 09/09/2015.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSBandwidthViewController.h"
#import "ETSBandwidthDetailViewController.h"
#import "ETSSynchronization.h"
#import "ETSBandwidth.h"
#import "ETSCoreDataHelper.h"
#import "ETSBandwidthCircleChart.h"

@interface ETSBandwidthViewController ()
    @property (nonatomic, strong) NSNumberFormatter *formatter;
    @property (nonatomic, strong) NSDateFormatter *dateFormatter;
    @property (nonatomic, copy) NSString *apartment;
    @property (nonatomic, copy) NSString *phase;
    @property (nonatomic, copy) NSString *month;
    @property (nonatomic, strong) NSNumber *usedBandwidth;
    @property (nonatomic, strong) NSNumber *limitBandwidth;
    @property (nonatomic, strong) NSURL* callCooptelUrl;
    @property (weak, nonatomic) IBOutlet UILabel *phaseLabel;
    @property (weak, nonatomic) IBOutlet UILabel *apartmentLabel;
    @property (weak, nonatomic) IBOutlet UIButton *detailButton;
    @property (weak, nonatomic) IBOutlet UIButton *callCooptelButton;
    @property (weak, nonatomic) IBOutlet UILabel *percentageLabel;
    @property (weak, nonatomic) IBOutlet UILabel *quotaLabel;
    @property (weak, nonatomic) IBOutlet UILabel *idealQuotaLabel;
    @property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
    @property (weak, nonatomic) IBOutlet ETSBandwidthCircleChart *circleChart;
@end

@implementation ETSBandwidthViewController

- (void)updateBandwidth:(id)sender
{
    [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    [self resetLabels];
    
    if ([self.phase length] == 0 || [self.apartment length] == 0) {
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    self.synchronization.request = [NSURLRequest requestForBandwidthWithMonth:self.month residence:self.apartment phase:self.phase];
    
    NSError *error;
    [self.synchronization synchronize:&error];
}

-(void)resetLabels {
    self.phaseLabel.text = @"";
    self.apartmentLabel.text = @"";
    self.percentageLabel.text = @"";
    self.quotaLabel.text = @"";
    self.idealQuotaLabel.text = @"";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    self.month = [@([[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:[NSDate date]] month]) stringValue];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.entityName = @"Bandwidth";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"query.results.table";
    synchronization.dateFormatter = self.dateFormatter;
    synchronization.predicate = [NSPredicate predicateWithFormat:@"month ==[c] %@", self.month];
    
    self.synchronization = synchronization;
    self.synchronization.delegate = self;
    
    // Call Cooptel
    self.callCooptelUrl = [NSURL URLWithString:@"telprompt:1-888-532-2667"];
    
    self.formatter = [[NSNumberFormatter alloc] init];
    self.formatter.decimalSeparator = @",";
    self.formatter.groupingSeparator = @" ";
    self.formatter.groupingSize = 3;
    self.formatter.usesGroupingSeparator = YES;
    self.formatter.maximumFractionDigits = 2;
    self.formatter.minimumFractionDigits = 1;
    self.formatter.minimumIntegerDigits = 1;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.apartment = [userDefaults stringForKey:@"apartment"];
    self.phase = [userDefaults stringForKey:@"phase"];
    
    [self resetLabels];
    
    if ([self.apartment length] == 0 || [self.phase integerValue] == 0) {
        self.dataNeedRefresh = NO;
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        [self performSegueWithIdentifier:@"SegueToConfig" sender:self];
    } else {
        self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", self.phase];
        self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", self.apartment];
        [self updateBandwidth:self];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!([self.apartment isEqualToString: [userDefaults stringForKey:@"apartment"]]) || !([self.phase isEqualToString: [userDefaults stringForKey:@"phase"]])) {
        self.apartment = [userDefaults stringForKey:@"apartment"];
        self.phase = [userDefaults stringForKey:@"phase"];
        
        self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", self.phase];
        self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", self.apartment];
        
        [self updateBandwidth:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowBandwidthDetails"]) {
        ETSBandwidthDetailViewController *destination = segue.destinationViewController;
        destination.managedObjectContext = self.managedObjectContext;
    }
}

- (IBAction)CallCooptelButton:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:self.callCooptelUrl]) {
        [[UIApplication sharedApplication] openURL:self.callCooptelUrl];
    }
}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    // Stopping activity indicator
    [self.activityIndicator stopAnimating];
    
    if (!objects || [objects isKindOfClass:[NSNull class]]) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        return nil;
    }
    
    NSMutableArray *entries = [NSMutableArray array];
    
    NSArray *tables = (NSArray *)objects;
    
    if ([tables count] < 2) {
        [ETSCoreDataHelper deleteAllObjectsWithEntityName:@"Bandwidth" inManagedObjectContext:self.managedObjectContext];
        [self performSegueWithIdentifier:@"SegueToConfig" sender:self];
        return nil;
    }
    
    NSArray *days = [[[tables objectAtIndex:0] valueForKey:@"tbody"] valueForKey:@"tr"];
    
    NSInteger i = 0;
    for (NSDictionary * day in days) {
        if (i++ == 0) continue;
        if ([day[@"td"] count] != 4) continue;
        
        NSString *date = day[@"td"][1];
        if ([date isEqualToString:@"Journée en cours"]) date = [self.dateFormatter stringFromDate:[NSDate date]];
        
        NSMutableDictionary *entry = [NSMutableDictionary dictionary];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[self.dateFormatter dateFromString:date]];
        
        [entry setValue:[[day valueForKey:@"td"]objectAtIndex:0] forKey:@"port"];
        [entry setValue:date forKey:@"date"];
        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:2]valueForKey:@"content" ] forKey:@"upload"];
        [entry setValue:[[[day valueForKey:@"td"]objectAtIndex:3]valueForKey:@"content" ] forKey:@"download"];
        [entry setValue:[@([components month]) stringValue] forKey:@"month  "];
        [entry setValue:[NSString stringWithFormat:@"%@-%@", [[day valueForKey:@"td"]objectAtIndex:0], date] forKey:@"id"];
        [entries addObject:entry];
    }
    
    // Appartement and Phase label update
    self.phaseLabel.text = [NSString stringWithFormat:@"Phase %@", self.phase];
    self.apartmentLabel.text = [NSString stringWithFormat:@"Appartement %@", self.apartment];
    
    // Enabling buttons
    self.detailButton.enabled = YES;
    
    if ([[UIApplication sharedApplication] canOpenURL:self.callCooptelUrl]) {
        self.callCooptelButton.enabled = YES;
    }
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.decimalSeparator = @".";
    self.usedBandwidth = [f numberFromString:[days lastObject][@"td"][1][@"content"]];
    self.limitBandwidth = [f numberFromString:tables[1][@"tbody"][@"tr"][1][@"td"][1][@"content"]];
    
    
    // Changing center percentage
    float used = [self.usedBandwidth floatValue] / 1024;
    float limit = [self.limitBandwidth floatValue] / 1024;
    self.percentageLabel.text = [NSString stringWithFormat:@"%@ Go", [self.formatter stringFromNumber:[NSNumber numberWithFloat:used]]];
    self.quotaLabel.text = [NSString stringWithFormat:@"sur %@ Go", [self.formatter stringFromNumber:[NSNumber numberWithFloat:limit]]];
    
    // Calculating Ideal Quota
    NSDate *today = [NSDate date]; //Get a date object for today's date
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:today];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange daysInMonth = [c rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:today];
    float idealQuota = [self.limitBandwidth floatValue] * [components day] / daysInMonth.length;
    float idealQuotaPercentage = [self.usedBandwidth floatValue]/idealQuota * 100;
    
    // Formatter pour le pourcentage
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.usesGroupingSeparator = NO;
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    formatter.minimumIntegerDigits = 1;
    
    self.idealQuotaLabel.text = [NSString stringWithFormat:@"%@ %% de la consommation idéale", [formatter stringFromNumber:[NSNumber numberWithFloat:idealQuotaPercentage]]];
    
    // Circle chart parameters
    self.circleChart.used = [self.usedBandwidth floatValue];
    self.circleChart.limit = [self.limitBandwidth floatValue];
    self.circleChart.ideal = idealQuota;
    [self.circleChart setNeedsDisplay];
    
    return entries;
}

@end
