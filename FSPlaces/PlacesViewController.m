//
//  PlacesViewController.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "PlacesViewController.h"
#import "FSVenueDetalsViewController.h"

#import "FSVenue.h"
#import "FSVenueAnnotation.h"

#import "UIView+Disable.h"
#import "UIAlertView+FSAlerts.h"
#import "FSMediator.h"

#import "AppDelegate.h"
#import <FSOAuth.h>

@interface PlacesViewController () <MKMapViewDelegate, UITableViewDelegate>

@property (strong, nonatomic) UIButton *showUserLocationButton;

- (IBAction)showUserLocation;
- (IBAction)refreshButtonTapped:(id)sender;
- (IBAction)segmentChanged:(id)sender;

@end

@implementation PlacesViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.venueDataSource = [VenueDataSource new];
        self.mediator = [FSMediator sharedMediator];
        self.mediator.placesController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disableMainView:)
                                                     name:FSNotificationShowProfile
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeToolbar];
    
    self.tableView.dataSource = self.venueDataSource;
    
    [self.mediator updateUserInformation];
    [self.mediator updateLocation];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom view elements

- (void)customizeToolbar
{
    self.showUserLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.showUserLocationButton setImage:[UIImage imageNamed:@"locationIcon.png"] forState:UIControlStateNormal];
    [self.showUserLocationButton addTarget:self action:@selector(showUserLocation) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
    [items insertObject:[[UIBarButtonItem alloc] initWithCustomView:self.showUserLocationButton] atIndex:0];
    [self.toolbar setItems:items];
    [self.segmentedControl setTintColor:[UIColor colorWithRed:189.0f/255.0f green:70.0f/255.0f blue:220.0f/255.0f alpha:1.0]];

}

#pragma mark - Web view 

- (void)showLogInForm
{
}

#pragma mark - Map View

- (void)updateMapViewRegion
{
    CGFloat maximumDistance = [[self.venueDataSource.venues valueForKeyPath:@"@max.distance"] floatValue];
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, maximumDistance, maximumDistance) animated:YES];
    
    self.map.showsUserLocation = YES;
}


- (void)plotVenuesOnMap
{
    [self.map removeAnnotations:self.map.annotations];
    self.map.showsUserLocation = YES;
    
    for (FSVenue *venue in self.venueDataSource.venues)
    {
        FSVenueAnnotation *annotation = [[FSVenueAnnotation alloc]
                                             initWithCoordinate:venue.location.coordinate name:venue.name url:venue.urlAddress andCategoryNames:[venue categoriesNames]];
        [self.map addAnnotation:annotation];
            
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *indentifier = @"FSAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:indentifier];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:indentifier];
    }
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    [annotationView setAnimatesDrop:YES];
    
    [annotationView setPinColor:MKPinAnnotationColorPurple];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

#pragma mark - Map view selection delegate

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    
    FSVenueAnnotation *annotation = (FSVenueAnnotation *)view.annotation;
    
    UIStoryboard *storyboard = self.storyboard;
    FSVenueDetalsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"VenueDetails"];
    
    FSVenue *matchedVenue = nil;
    for (FSVenue *venue in self.venueDataSource.venues) {
        if ([venue.name isEqualToString:annotation.name]) {
            matchedVenue = venue;
        }
    }
    [controller setVenue:matchedVenue];
    controller.title = annotation.name;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view selection delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VenueDetails"]) {
        FSVenueDetalsViewController *controller = segue.destinationViewController;
        FSVenue *venue = [self.venueDataSource.venues objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        [controller setVenue:venue];
        controller.title = venue.name;
    }
}

#pragma mark - Actions

- (IBAction)segmentChanged:(id)sender
{
    [self showUIWithStyle:[sender selectedSegmentIndex]];
}

- (void)showUIWithStyle:(PlacesViewStyle)viewStyle
{
    switch (viewStyle) {
        case PlacesViewStyleMap:
        {
            self.tableView.hidden = YES;
            self.map.hidden = NO;
            self.showUserLocationButton.hidden = NO;
            [self plotVenuesOnMap];
            break;
        }
        case PlacesViewStyleTable:
        {
            self.tableView.hidden = NO;
            self.map.hidden = YES;
            self.showUserLocationButton.hidden = YES;
            [self.tableView reloadData];
            break;
        }
        default:
            break;
    }
    
    [self.mediator setShownViewStyle:viewStyle];

}

- (IBAction)refreshButtonTapped:(id)sender {
    [self.mediator updateUserInformation];
    [self.mediator updateLocation];
}

- (IBAction)showUserLocation
{
    if (self.currentLocation) {
        [self updateMapViewRegion];
    }
    else {
        [[UIAlertView locationErrorAlert] show];
    }
    
}


#pragma mark - Notification handler
- (void)disableMainView:(NSNotification *)notification
{
    BOOL disable = [[notification.userInfo objectForKey:FSNotificationShowProfileKey] boolValue];
    
    [self.profileView rotateArrowDown:!disable];
    
    
    [UIView animateWithDuration:1.0 animations:^(){
        
        if (self.segmentedControl.selectedSegmentIndex == 0) {
            [self.map setDisabled:disable withAlpha:0.8];
        }
        else
        {
            [self.tableView setDisabled:disable withAlpha:0.8];
        }
        [self.toolbar setDisabled:disable withAlpha:0.8];
        
    }];
}


@end