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
    // Uncomment the following line to preserve selection between presentations.
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
            NSIndexPath *path = [NSIndexPath indexPathForRow:!indexPath.row inSection:0];
            [tableView cellForRowAtIndexPath:path].accessoryType = UITableViewCellAccessoryNone;
            
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            
            switch (indexPath.row) {
                case 0:
                    [[FSConnectionManager sharedManager] findVenuesNearbyMeWithLimit:20];
                    break;
                case 1:
                    [[FSConnectionManager sharedManager] findCheckedInVenues];
                    break;
            }
            
            [[FSMediator sharedMediator] profileActionSelected];
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

@end
