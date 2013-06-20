//
//  PlacesViewController.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "PlacesViewController.h"
#import "FSConnectionManager.h"
#import "FSLocationManager.h"
#import "FSVenue.h"
#import "FSUser.h"
#import "FSVenueAnnotation.h"
#import "UIView+Disable.h"
#import "FSVenueDetalsViewController.h"
#import "UIAlertView+FSAlerts.h"

#define MAP_REGION 300
#define MAP_BIG_REGION 3000
#define VENUES_LIMIT 20

@interface PlacesViewController () <MKMapViewDelegate, UIWebViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic, readwrite) UIWebView *webView;

@property (nonatomic) BOOL refreshLocation;

- (IBAction)updateLocation;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)reloadInformation:(id)sender;

@end

@implementation PlacesViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        self.mediator = [FSMediator sharedMediator];
        self.mediator.mainController = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(disableMainView:)
                                                     name:@"FSNotificationShowProfile"
                                                   object:nil];

    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FSNotificationShowProfile" object:nil];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customizeToolbar];
    
    [self showSegment:0];
    [self logIn];
        
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom view elements

- (void)customizeToolbar
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"locationIcon.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(updateLocation) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray *items = [NSMutableArray arrayWithArray:self.toolbar.items];
    [items insertObject:[[UIBarButtonItem alloc] initWithCustomView:button] atIndex:0];
    [self.toolbar setItems:items];

}

#pragma mark - Web view 

- (void)showWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.webView loadRequest:[[FSConnectionManager sharedManager] tokenRequest]];
    
    [self.view addSubview:self.webView];

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"itms-apps"])
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    BOOL success = [[FSConnectionManager sharedManager] extractTokenFromResponseURL:[self.webView.request URL]];
    if (success)
    {
        [self.webView removeFromSuperview];
        self.webView = nil;
        
        [self updateInformation];
    }
}


#pragma mark - Map View

- (void)updateMapView
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
    
    for (FSVenue *venue in self.venuesToShow)
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
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:indentifire];
    
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    FSVenueAnnotation *annotation = (FSVenueAnnotation *)view.annotation;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    FSVenueDetalsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"VenueDetails"];
    
    [controller setUrl:annotation.url];
    controller.title = annotation.name;
    
    [self.map deselectAnnotation:annotation animated:YES];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[UIAlertView locationErrorAlert] show];
    });
}

#pragma mark - Setters

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    _currentLocation = currentLocation;
    [self updateMapView];
    [[FSConnectionManager sharedManager] findVenuesNearbyMeWithLimit:VENUES_LIMIT];
}

- (void)setLastCheckinLocation:(CLLocation *)lastCheckinLocation
{
    _lastCheckinLocation = lastCheckinLocation;
    [self updateMapView];
}

-(void)setCurrentUser:(FSUser *)currentUser
{
    _currentUser = currentUser;
    self.profileView.imageURL = self.currentUser.photoURL;
    self.profileView.userName = [self.currentUser fullName];
    self.profileView.isShown = NO;
    
    [UIView animateWithDuration:1.0 animations:^() {
        self.profileView.hidden = NO;
    }];
    
}

- (void)setVenuesToShow:(NSArray *)venuesToShow
{
    _venuesToShow = venuesToShow;
    [self plotVenuesOnMap];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venuesToShow.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    FSVenue *venue = [self.venuesToShow objectAtIndex:indexPath.row];
    
    cell.textLabel.text = venue.name;
    if (self.lastCheckinLocation) {
        cell.detailTextLabel.text = @"";
    }
    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f m", venue.distance];
    return cell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO];
}
#pragma mark - Segmented control

- (IBAction)segmentChanged:(id)sender
{
    [self showSegment:[sender selectedSegmentIndex]];
}

- (void)showSegment:(int)segmentNumber
{
    switch (segmentNumber) {
        case 0:
        {
            self.tableView.hidden = YES;
            self.map.hidden = NO;
            break;
        }
        case 1:
        {
            self.tableView.hidden = NO;
            self.map.hidden = YES;
            break;
        }
        default:
            break;
    }

}

#pragma mark - other

- (void)logIn
{
    if (![[FSConnectionManager sharedManager] isActive])
    {
        [self showWebView];
    }
    
    else [self updateInformation];
}

-  (void)updateInformation
{
    [self updateLocation];
    
    [[FSConnectionManager sharedManager] requestCurrentUserInformation];
}

- (IBAction)updateLocation
{
    self.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
}

- (IBAction)reloadInformation:(id)sender {
    if (!self.currentUser) {
        
        [[FSConnectionManager sharedManager] requestCurrentUserInformation];
    }
    self.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    if (!self.currentLocation) {
        [self locationManager:nil didFailWithError:nil];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"VenueDetails"]) {
        FSVenueDetalsViewController *controller = segue.destinationViewController;
        FSVenue *venue = [self.venuesToShow objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        [controller setUrl:venue.urlAddress];
        controller.title = venue.name;
    }
}

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