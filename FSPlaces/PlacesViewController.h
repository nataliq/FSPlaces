//
//  PlacesViewController.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "FSMediator.h"

#import "ProfileSwipeView.h"
#import "VenueDataSource.h"

typedef enum
{
    PlacesViewStyleMap,
    PlacesViewStyleTable
    
} PlacesViewStyle;

@interface PlacesViewController : UIViewController


@property (assign, nonatomic) id<FSMediator> mediator;

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) VenueDataSource *venueDataSource;

@property (weak, nonatomic) IBOutlet ProfileSwipeView *profileView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *lastCheckinLocation;

- (void)showLogInForm;
- (void)updateMapViewRegion;
- (void)plotVenuesOnMap;

@end
