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

#define MAP_REGION 300
#define MAP_BIG_REGION 3000

@interface PlacesViewController () <MKMapViewDelegate, UITableViewDelegate>

@property (strong, nonatomic, readwrite) UIWebView *webView;
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
                                                     name:@"FSNotificationShowProfile"
                                                   object:nil];

    }
    
    return self;
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self.venueDataSource;
    
    [self customizeToolbar];
    
    [self.mediator updateUserInformation];
    [self.mediator updateLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.webView = nil;
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

}

#pragma mark - Web view 

- (void)showLogInForm
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self.mediator;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadRequest:[[FSConnectionManager sharedManager] tokenRequest]];
    
    [self.view addSubview:self.webView];

}

#pragma mark - Map View

- (void)updateMapViewRegion
{
    if (self.lastCheckinLocation) {
        [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.lastCheckinLocation.coordinate, MAP_BIG_REGION, MAP_BIG_REGION)];
    }
    else if (self.currentLocation) {
        [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, MAP_REGION, MAP_REGION)];
    }
    
    self.map.showsUserLocation = YES;
}


- (void)plotVenuesOnMap
{
    [self.map removeAnnotations:self.map.annotations];
    self.map.showsUserLocation = YES;
    
    for (FSVenue *venue in self.venueDataSource.venues)
    {
        FSVenueAnnotation *annotation = [[FSVenueAnnotation alloc]
                                             initWithCoordinate:venue.location.coordinate name:venue.name url:venue.urlAddress andCategoryNames:[venue categories]];
        [self.map addAnnotation:annotation];
            
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    NSString *indentifire = @"FSAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:indentifire];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:indentifire];
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
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
        if (self.lastCheckinLocation) {
            [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, MAP_BIG_REGION, MAP_BIG_REGION) animated:YES];
        }
        else if (self.currentLocation) {
            [self.map setRegion:MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, MAP_REGION, MAP_REGION) animated:YES];
        }
        
        self.map.showsUserLocation = YES;

    }
    else {
        [[UIAlertView locationErrorAlert] show];
    }
    
}


#pragma mark - Notification handler
- (void)disableMainView:(NSNotification *)notification
{
    BOOL disable = [[notification.userInfo objectForKey:@"showProfile"] boolValue];
    
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