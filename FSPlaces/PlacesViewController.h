//
//  PlacesViewController.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "FSConnectionManagerDelegate.h"
#import "ProfileSwipeView.h"
#import "FSMediator.h"

@interface PlacesViewController : UIViewController <FSConnectionManagerDelegate>


@property (assign, nonatomic) id<FSMediator> mediator;

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ProfileSwipeView *profileView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CLLocation *lastCheckinLocation;
@property (strong, nonatomic) FSUser *currentUser;
@property (strong, nonatomic) NSArray *venuesToShow;


@end
