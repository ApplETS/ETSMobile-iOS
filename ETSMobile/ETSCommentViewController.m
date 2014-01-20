//
//  ETSCommentViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 1/20/2014.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCommentViewController.h"
#import "ETSCommentCell.h"
#import "MFSideMenu.h"
#import "NSURLRequest+API.h"

@interface ETSCommentViewController ()

- (IBAction)sendComment:(id)sender;

@end

@implementation ETSCommentViewController

- (void)panLeftMenu
{
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(panLeftMenu)];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 3;
    else if (section == 1) return 1;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentIdentifier";
    ETSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.label.text = @"Nom :";
        }
        else if (indexPath.row == 1) {
            cell.label.text = @"Courriel :";
        }
        else if (indexPath.row == 1) {
            cell.label.text = @"Appréciation :";
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Mes informations";
    else if (section == 1) return @"Mon commentaire";
    else return nil;
}


- (IBAction)sendComment:(id)sender
{
    NSString *name = ((ETSCommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).label.text;
    NSString *email = ((ETSCommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).label.text;
/*
    [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestForCommentWithName:@"J.P. Martin" email:@"jphilippe.martin@icloud.com" title:@"ÉTSMobile-iOS : Commentaire" rating:@"5 sur 5" comment:@"Test d'envoi de courriel pour les commentaires sur ÉTSMobile 2.0"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
    }]; */
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestForCommentWithName:@"J.P. Martin" email:@"jphilippe.martin@icloud.com" title:@"ÉTSMobile-iOS : Commentaire" rating:@"5 sur 5" comment:@"Test d'envoi de courriel pour les commentaires sur ÉTSMobile 2.0"]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data,
                                               NSError *connectionError) {
                               NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
                           }];
    
    
}

@end
