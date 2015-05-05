//
//  ETSMoodleCourseResultsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-04-08.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSMoodleCourseResultsViewController.h"
#import "ETSMoodleElement.h"

@implementation ETSMoodleCourseResultsViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredProducts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoodleResultCell" forIndexPath:indexPath];
    ETSMoodleElement *element = self.filteredProducts[indexPath.row];
    cell.textLabel.text = element.name;

    return cell;
}

@end
