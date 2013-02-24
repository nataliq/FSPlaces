//
//  PlacesViewController.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "PlacesViewController.h"
#import "FSConnectionManager.h"
#import "FSLocationManager.h"
#import "FSVenue.h"
#import "FSVenueAnnotation.h"

#define MAP_REGION 500
#define VENUES_LIMIT 20

@interface PlacesViewController () <MKMapViewDelegate, UIWebViewDelegate>

@property (strong, nonatomic, readwrite) UIWebView *webView;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end

@implementation PlacesViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(enableMapView:)
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
   
    if (![FSConnectionManager isActive])
    {
        [self showWebView];
    }
    
    else [self plotVenuesNearbyMe];
    
    
    [FSConnectionManager saveCurrentUser];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web view 

- (void)showWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.webView loadRequest:[FSConnectionManager tokenRequest]];
    
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
    
    BOOL success = [FSConnectionManager extractTockenFromResponseURL:[self.webView.request URL]];
    if (success)
    {
        [self.webView removeFromSuperview];
        [self plotVenuesNearbyMe];
    }
}


#pragma mark - Map View

- (void)plotVenuesNearbyMe
{
    CLLocation *location = [[FSLocationManager sharedManager] getCurrentLocation];
    [self.map setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, MAP_REGION, MAP_REGION)];
    
    NSArray *venues = [FSConnectionManager findVenuesNearbyMeWithLimit:VENUES_LIMIT];
    for (FSVenue *venue in venues)
    {
        
        FSVenueAnnotation *annotation = [[FSVenueAnnotation alloc]
                                         initWithCoordinate:venue.location.coordinate name:venue.name andCategoryNames:venue.categoryNames];
        [self.map addAnnotation:annotation];
        
    }
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *indentifire = @"fsqAnnotation";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.map dequeueReusableAnnotationViewWithIdentifier:indentifire];
    
    if (annotationView == nil)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:indentifire];
    }
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)enableMapView:(NSNotification *)notification
{
    BOOL enable = ![[notification.userInfo objectForKey:@"showProfile"] boolValue];
    
    [UIView animateWithDuration:0.5 animations:^() {
        float angle = (enable) ? 0 : M_PI;
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    [UIView animateWithDuration:1.0 animations:^(){
        
        self.map.alpha = (enable) ? 1 : 0.8;
        self.map.userInteractionEnabled = enable;
        self.map.scrollEnabled = enable;
        self.map.zoomEnabled = enable;
    }];
}

@end
