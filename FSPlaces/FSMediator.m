//
//  FSMediator.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSMediator.h"
#import "FSVenue.h"
#import "PlacesViewController.h"

#import "UIAlertView+FSAlerts.h"

#import "FSConnectionManager.h"
#import "FSLocationManager.h"
#import "FSRecommender.h"

@interface FSMediator () <UIAlertViewDelegate>

@property (strong, nonatomic) FSUser *currentUser;
@property (assign, nonatomic) PlacesViewStyle shownViewStyle;
@property (assign, nonatomic) ShowVenuesType shownVenueType;

@property (strong, nonatomic) NSArray *venuesForRecommendation;

@end

@implementation FSMediator

#pragma mark - Singleton

static FSMediator* sharedMediator = nil;
static NSInteger sourcesCount = 0;
static NSInteger runningCategoryRequestsCount = 0;

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

#pragma mark - Web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"fsplaces"]) {
        BOOL success = [[FSConnectionManager sharedManager] extractTokenFromResponseURL:request.URL];
        if (success) {
            [webView removeFromSuperview];
            webView = nil;
            
            [self updateUserInformation];
            [self updateLocation];
        }
        return NO;
    }
    return YES;
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
        NSLog(@"Location error: %@", error.debugDescription);
    });
}

#pragma mark - Connection manager delegate

- (void)setVenuesToShow:(NSArray *)venues
{
    NSArray *venuesSortedByDistance = [venues sortedArrayUsingComparator:^NSComparisonResult(FSVenue *v1, FSVenue *v2) {
        return (NSComparisonResult) [@(v1.distance) compare:@(v2.distance)];;
    }];
    
    [self.placesController.venueDataSource setVenues:venuesSortedByDistance];
    //[self saveVenuesInPList];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        if (self.shownViewStyle == PlacesViewStyleMap) {
            [self.placesController updateMapViewRegion];
            [self.placesController plotVenuesOnMap];
        }
        else {
            [self.placesController.tableView reloadData];
        }
    });
}

- (void)setLastCheckinLocation:(CLLocation *)location
{
    [self.placesController setLastCheckinLocation:location];
    self.shownVenueType = location ? ShowVenuesTypeAround : ShowVenuesTypeChecked;
}

- (void)addVenuesForTraining:(NSArray *)venues
{
    sourcesCount++;
    if (venues) [[FSRecommender sharedRecomender] addVenuesToTrainingSet:venues];
    
    if (sourcesCount == 2) {
        NSArray *categoryIds = [[FSRecommender sharedRecomender] filteredCategoryIdsForTestSet];
        runningCategoryRequestsCount = categoryIds.count;
        for (NSString *categoryId in categoryIds) {
            [[FSConnectionManager sharedManager] findNearVenuesForCategoryId:categoryId];
        }
    }
}

- (void)addVenuesForRecommendation:(NSArray *)venues
{
    runningCategoryRequestsCount--;
    if (venues) [[FSRecommender sharedRecomender] addVenuesToTestSet:venues];
    
    if (runningCategoryRequestsCount == 0) {
        self.venuesForRecommendation = [[FSRecommender sharedRecomender] filteredItemsToRecommend];
        [[[UIAlertView alloc] initWithTitle:@"Hey, we found some interesting places!" message:@"We think that you may be interested in checking out some cool places around you" delegate:self cancelButtonTitle:@"View places" otherButtonTitles: nil] show];
    }
}

- (void)setShownViewStyle:(PlacesViewStyle)shownViewStyle
{
    _shownViewStyle = shownViewStyle;
}

#pragma mark - Update PlacesViewController UI
- (void)updateUserInformation
{
    if (![[FSConnectionManager sharedManager] isActive]) {
        [self.placesController showLogInForm];
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            [self loadUserInfo];
        });
    }
}

- (void)loadUserInfo
{
    if (!self.currentUser) {
        
        self.currentUser = [[FSConnectionManager sharedManager] requestCurrentUserInformation];
        
        if (self.currentUser) {
            dispatch_async(dispatch_get_main_queue(), ^(){
                [self.placesController.profileView populateWithUserInformation:self.currentUser];
                [self.placesController.profileView setHidden:NO animated:YES];
            });
        }
    }
}

- (void)updateLocation
{
    self.placesController.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    
    if (self.placesController.currentLocation) {
        [self.placesController updateMapViewRegion];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        if (self.placesController.currentLocation && self.shownViewStyle == ShowVenuesTypeAround) {
            [self.placesController.venueDataSource requestVenues];
        }
        else if([[FSConnectionManager sharedManager] isActive]){
            [self.placesController.venueDataSource requestCheckedVenues];
            self.shownVenueType = ShowVenuesTypeChecked;
        }
        if (self.placesController.currentLocation) {
            [[FSConnectionManager sharedManager] getAllCheckinHistory];
            [[FSConnectionManager sharedManager] getTODOs];
        }
    });
    
}

- (void)profileActionSelected
{
    [self.placesController.profileView swipeUp];
}

- (ShowVenuesType)shownType
{
    return self.shownVenueType;
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self setVenuesToShow:self.venuesForRecommendation];
    }
}

#pragma mark - Helpers

- (void)saveVenuesInPList
{
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    destPath = [destPath stringByAppendingPathComponent:@"venues.plist"];
    
    // If the file doesn't exist in the Documents Folder, copy it.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:destPath]) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"venues" ofType:@"plist"];
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
    }
    
    // Load the Property List.
}

@end