//
//  PlacesViewController.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "PlacesViewController.h"
#import "FSConnectionManager.h"
#import "FSVenue.h"
#import "FSVenueAnnotation.h"

#define MAP_CENTER_LAT 42.685685
#define MAP_CENTER_LONG 23.319125
#define MAP_REGION 500

@interface PlacesViewController () <MKMapViewDelegate>

@property (strong, nonatomic, readwrite) UIWebView *webView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation PlacesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    if (![FSConnectionManager isActive]) {
        [self showWebView];
    }
    
    [self plotVenuesNearbyMe];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = MAP_CENTER_LAT;
    centerCoordinate.longitude = MAP_CENTER_LONG;
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(centerCoordinate, MAP_REGION, MAP_REGION)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableMapView:)
                                                 name:@"FSNotificationShowProfile"
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy getter

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

#pragma mark - Web view 

- (void)showWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.webView loadRequest:[FSConnectionManager tokenRequest]];
    
    [self.view addSubview:self.webView];

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"itms-apps"]) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    BOOL success = [FSConnectionManager extractTockenFromResponseURL:[self.webView.request URL]];
    if (success) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations objectAtIndex:0];
}

#pragma mark - MKMap

- (void)plotVenuesNearbyMe
{
    NSArray *venues = [FSConnectionManager findVenuesNearby:self.locationManager.location limit:20 searchterm:nil];
    
    for (FSVenue *venue in venues) {
        
        FSVenueAnnotation *annotation = [[FSVenueAnnotation alloc]
                                         initWithCoordinate:venue.location.coordinate name:venue.name andCategoryNames:venue.categoryNames];
        
        [self.map addAnnotation:annotation];
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *indentifire = @"mmAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:indentifire];
    
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:indentifire];
    }
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)enableMapView:(NSNotification *)notification
{
    BOOL enable = ![[notification.userInfo objectForKey:@"show"] boolValue];
    [UIView animateWithDuration:1.0 animations:^(){
        float angle = (enable) ? 0 : M_PI;
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
        self.map.alpha = (enable) ? 1 : 0.5;
        self.map.userInteractionEnabled = enable;
        self.map.scrollEnabled = enable;
        self.map.zoomEnabled = enable;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FSNotificationShowProfile" object:nil];
}
@end
