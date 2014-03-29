//
//  ETSCalendarViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-03-24.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCalendarViewController.h"
#import "NSURLRequest+API.h"

@interface ETSCalendarViewController ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation ETSCalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm"];
    
    ETSSynchronization *synchronization = [[ETSSynchronization alloc] init];
    synchronization.request = [NSURLRequest requestForCalendar];
    synchronization.entityName = @"Calendar";
    synchronization.compareKey = @"id";
    synchronization.objectsKeyPath = @"d.ListeDesSeances";
    synchronization.dateFormatter = self.dateFormatter;
    self.synchronization = synchronization;
    self.synchronization.delegate = self;

}

- (id)synchronization:(ETSSynchronization *)synchronization updateJSONObjects:(id)objects
{
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:[objects count]];
    
    for (NSDictionary *object in objects) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:object];
        
        event[@"dateDebut"] = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[object[@"dateDebut"] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue]/1000]];
        event[@"dateFin"] = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[[object[@"dateFin"] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue]/1000]];
        event[@"id"] = [NSString stringWithFormat:@"%@%@%@", event[@"dateDebut"], event[@"dateFin"], event[@"coursGroupe"]];
        
        [events addObject:event];
    }
    return events;
}

@end
