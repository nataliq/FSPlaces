//
//  VenueDataSource.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/21/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "VenueDataSource.h"
#import "FSVenue.h"
#import "FSVenueCell.h"

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
    FSVenueCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VenueCell"];
    
    FSVenue *venue = [self.venues objectAtIndex:indexPath.row];    
    [cell configureWithVenue:venue];

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
