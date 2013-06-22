//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "ProfileActionsTableViewController.h"
#import "FSConnectionManager.h"
#import "FSMediator.h"

@implementation ProfileActionsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndex:) name:@"GetVenuesRequestResolved" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndex:) name:@"GetCheckedVenuesRequestResolved" object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {

            switch (indexPath.row) {
                case 0:
                    [[FSConnectionManager sharedManager] findVenuesNearbyMeWithLimit:20];
                    break;
                case 1:
                    [[FSConnectionManager sharedManager] findCheckedInVenues];
                    break;
            }

        }
            break;
        case 1:
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[FSConnectionManager sharedManager] cancelConnection];
            break;
        }
    }

}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:!indexPath.row inSection:0];
    [self.tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
}

#pragma mark - Notification handler

- (void)selectIndex:(NSNotification *)notification
{
    NSIndexPath *path = nil;
    if ([notification.name isEqualToString:@"GetVenuesRequestResolved"]) {
        path = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    else {
        path = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    [self selectRowAtIndexPath:path];
    [[FSMediator sharedMediator] profileActionSelected];
}

@end
