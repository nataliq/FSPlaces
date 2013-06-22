//
//  VenueDataSource.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/21/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "VenueDataSource.h"
#import "FSVenue.h"

#define VENUES_LIMIT 20

@implementation VenueDataSource

#pragma mark - Table view data source

- (id)init
{
    self = [super init];
    if (self) {
        self.connectionManager = [FSConnectionManager sharedManager];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    FSVenue *venue = [self.venues objectAtIndex:indexPath.row];
    
    cell.textLabel.text = venue.name;
    if (venue.distance == 0) {
        cell.detailTextLabel.text = @"";
    }
    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f m", venue.distance];
    
    return cell;
}

- (void)requestVenues
{
    [self.connectionManager findVenuesNearbyMeWithLimit:VENUES_LIMIT];
}

- (void)requestCheckedVenues
{
    [self.connectionManager findCheckedInVenues];
}


@end
