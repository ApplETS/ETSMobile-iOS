//
//  ETSCommentViewController.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 1/20/2014.
//  Copyright (c) 2014 ApplETS. All rights reserved.
//

#import "ETSCommentViewController.h"
#import "ETSCommentCell.h"
#import "ETSRateCell.h"
#import "ETSTextCell.h"
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
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
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommentIdentifier" forIndexPath:indexPath];
            ((ETSCommentCell *)cell).label.text = NSLocalizedString(@"Nom :", nil);
            ((ETSCommentCell *)cell).textField.placeholder = NSLocalizedString(@"Prénom et nom", nil);
        }
        else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CommentIdentifier" forIndexPath:indexPath];
            ((ETSCommentCell *)cell).label.text = NSLocalizedString(@"Courriel :", nil);
            ((ETSCommentCell *)cell).textField.placeholder = NSLocalizedString(@"votre@courriel.com", nil);
        }
        else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"RateIdentifier" forIndexPath:indexPath];
            ((ETSRateCell *)cell).label.text = NSLocalizedString(@"Appréciation :", nil);
        }
    }
    else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TextIdentifier" forIndexPath:indexPath];
        ((ETSTextCell *)cell).textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return NSLocalizedString(@"Mes informations", nil);
    else if (section == 1) return NSLocalizedString(@"Mon commentaire", nil);
    else return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? 44 : 190;
}


- (IBAction)sendComment:(UIBarButtonItem *)sender
{
    NSString *name = [((ETSCommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [((ETSCommentCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *comment = [((ETSTextCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSInteger rating = ((ETSRateCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]).rating;
    
    if ([name length] == 0 || [email length] == 0 || [comment length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Formulaire incomplet", nil) message:NSLocalizedString(@"Vous vous assurer d'entrer votre nom, courriel et commentaire", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    else {
        sender.enabled = NO;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        __weak typeof(self) bself = self;
        
        NSURLRequest *request = [NSURLRequest requestForCommentWithName:name email:email title:@"ÉTSMobile-iOS : Commentaire" rating:[NSString stringWithFormat:@"%li sur 5", (long)rating] comment:comment];
         
        NSLog(@"%@", [NSString stringWithUTF8String:[[request HTTPBody] bytes]]);
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            NSLog(@"%@", [NSString stringWithUTF8String:[data bytes]]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Commentaire envoyé", nil) message:NSLocalizedString(@"ApplETS vous remercie pour vos idées et commentaires. Un membre vous contactera sous peu.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                ((ETSCommentCell *)[bself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]).textField.text = @"";
                
                ((ETSCommentCell *)[bself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField.text = @"";
                
                ((ETSTextCell *)[bself.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textView.text = @"";
                
                
                sender.enabled = YES;
            });
        }];
        
        [task resume];
    }
}

@end
