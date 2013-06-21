//
//  FSMediator.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSMediator.h"
#import "PlacesViewController.h"

#import "UIAlertView+FSAlerts.h"

#import "FSConnectionManager.h"
#import "FSLocationManager.h"

@interface FSMediator ()

@property (strong, nonatomic) FSUser *currentUser;
@property (assign, nonatomic) PlacesViewStyle shownViewStyle;

@end

@implementation FSMediator

#pragma mark - Singleton

static  FSMediator* sharedMediator = nil;

+ (FSMediator *)sharedMediator
{
    if (!sharedMediator) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedMediator = [[FSMediator alloc] init];
        });
    }
    return sharedMediator;
}

- (id)init {
    
	self = [super init];
	if (self)
    {
        
    }
    
	return self;
}
#pragma mark - web view delegate

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
    
    BOOL success = [[FSConnectionManager sharedManager] extractTokenFromResponseURL:[webView.request URL]];
    if (success)
    {
        [webView removeFromSuperview];
        webView = nil;
        
        [self updateUserInformation];
        [self updateLocation];
    }
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    self.placesController.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        [[UIAlertView locationErrorAlert] show];
    });
}

#pragma mark - setters

- (void)setVenuesToShow:(NSArray *)venues
{
    [self.placesController.venueDataSource setVenues:venues];
    
    if (self.shownViewStyle == PlacesViewStyleMap) {
        [self.placesController updateMapViewRegion];
        [self.placesController plotVenuesOnMap];
    }
    else {
        [self.placesController.tableView reloadData];
    }

}

- (void)setLastCheckinLocation:(CLLocation *)location
{
    [self.placesController setLastCheckinLocation:location];
}

#pragma mark - update places view controller ui
- (void)updateUserInformation
{
    if (![[FSConnectionManager sharedManager] isActive])
    {
        [self.placesController showLogInForm];
    }
    
    else
    {
        self.currentUser = [[FSConnectionManager sharedManager] requestCurrentUserInformation];
        
        if (self.currentUser) {
            [self.placesController.profileView populateWithUserInformation:self.currentUser];
            [self.placesController.profileView showAnimated:YES];
        }
    
    }

}

- (void)updateLocation
{
    self.placesController.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    [self.placesController updateMapViewRegion];
    [self.placesController.venueDataSource updateVenues];

}

- (void)showMap
{
    [self.placesController showUIWithStyle:PlacesViewStyleMap];
    
}

- (void)profileActionSelected
{
    [self.placesController.profileView hide];
}
@end
