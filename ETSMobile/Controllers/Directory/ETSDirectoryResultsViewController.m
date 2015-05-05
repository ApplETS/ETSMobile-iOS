//
//  ETSDirectoryResultsViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2015-04-07.
//  Copyright (c) 2015 ApplETS. All rights reserved.
//

#import "ETSDirectoryResultsViewController.h"
#import "ETSContact.h"

@implementation ETSDirectoryResultsViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredProducts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultCell" forIndexPath:indexPath];
    
    ETSContact *contact = self.filteredProducts[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
    
    return cell;
}

@end
