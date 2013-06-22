//
//  VenueDataSource.h
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/21/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "FSConnectionManager.h"

@interface VenueDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSArray *venues;
@property (assign, nonatomic) FSConnectionManager *connectionManager;

- (void)requestVenues;
- (void)requestCheckedVenues;

@end
