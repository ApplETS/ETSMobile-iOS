//
//  ETSNewsSourceViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2014-01-15.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSNewsSourceViewController.h"

@interface NSMutableDictionary (Source)
- (BOOL)isSourceEnabled;
- (void)setSourceEnabled:(BOOL)enabled;
@end

@implementation NSMutableDictionary (Source)

- (BOOL)isSourceEnabled
{
    return [self[@"enabled"] boolValue];
}

- (void)setSourceEnabled:(BOOL)enabled
{
    self[@"enabled"] = enabled ? @YES : @NO;
}

@end

@interface ETSNewsSourceViewController ()

@end

@implementation ETSNewsSourceViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:nil];
    [self.sources writeToFile:self.savePath atomically:YES];

    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SourceIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self.sources[indexPath.row] objectForKey:@"name"];
    cell.accessoryType = ([self.sources[indexPath.row] isSourceEnabled] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
    cell.imageView.image = [UIImage imageNamed:[self.sources[indexPath.row] objectForKey:@"backgroundImageName"]];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Sources à afficher :";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.sources[indexPath.row] setSourceEnabled:![self.sources[indexPath.row] isSourceEnabled]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
