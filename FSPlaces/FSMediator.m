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
#import "FSCategoriesController.h"
#import "CategoriesDataSource.h"

@interface FSMediator () <UIAlertViewDelegate>

@property (strong, nonatomic) FSUser *currentUser;
@property (assign, nonatomic) PlacesViewStyle shownViewStyle;
@property (assign, nonatomic) ShowVenuesType shownVenueType;

@property (strong, nonatomic) NSArray *venuesForRecommendation;
@property (strong, nonatomic) UIViewController *categoriesController;

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

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FSNotificationLocationServicesAreEnabled object:nil];
    }
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
        return (NSComparisonResult) [@(v1.distance) compare:@(v2.distance)];
    }];
    [self updateVenues:venuesSortedByDistance];
}

- (void)setLastCheckinLocation:(CLLocation *)location
{
    [self.placesController setLastCheckinLocation:location];
    self.shownVenueType = location ? ShowVenuesTypeAround : ShowVenuesTypeChecked;
}

- (void)addVenuesForTraining:(NSArray *)venues
{
    FSRecommender *recommender = [FSRecommender sharedRecomender];
    sourcesCount++;
    if (venues) [recommender addVenuesToTrainingSet:venues];
    
    if (sourcesCount == 2) {
        [recommender analyzeTrainingSet];
        [self showCategoriesController:[recommender trainingCategoriesInfo]];
        [self requestVenuesForCategoryIds:[recommender filteredCategoryIdsForTestSet]];
    }
}

- (void)addVenuesForRecommendation:(NSArray *)venues
{
    runningCategoryRequestsCount--;
    if (venues) [[FSRecommender sharedRecomender] addVenuesToTestSet:venues];
    
    if (runningCategoryRequestsCount == 0) {
        self.venuesForRecommendation = [[FSRecommender sharedRecomender] filteredItemsToRecommend];
        if (!self.categoriesController) {
            [self showVenuesToRecommend];
        }
    }
}

- (void)showVenuesToRecommend
{
    if (self.venuesForRecommendation) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Hey, we found some interesting places!"
                                        message:@"We think that you may be interested in checking out some cool places around you"
                                       delegate:self
                              cancelButtonTitle:@"View places"
                              otherButtonTitles: nil]
             show];
            
        });
    }
    self.categoriesController = nil;
}

- (void)setShownViewStyle:(PlacesViewStyle)shownViewStyle
{
    _shownViewStyle = shownViewStyle;
}

#pragma mark - Update PlacesViewController UI
- (void)updateUserInformation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        if (!self.currentUser) {
            
            self.currentUser = [[FSConnectionManager sharedManager] requestCurrentUserInformation];
            
            if (self.currentUser) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.placesController.profileView populateWithUserInformation:self.currentUser];
                    [self.placesController.profileView setHidden:NO animated:YES];
                });
            }
        }
    });
}

- (void)updateLocation
{
    self.placesController.currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    
    if (self.placesController.currentLocation) {
        [self.placesController updateMapViewRegion];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(){
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

- (void)updateVenues:(NSArray *)venues
{
    [self.placesController.venueDataSource setVenues:venues];
    
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

- (void)profileActionSelected
{
    [self.placesController.profileView swipeUp];
}

- (ShowVenuesType)shownType
{
    return self.shownVenueType;
}

#pragma mark - Show modal controller 

- (void)showCategoriesController:(NSDictionary *)categoriesInfo
{
    UIStoryboard *storyboard = self.placesController.storyboard;
    FSCategoriesController *vc = [storyboard instantiateViewControllerWithIdentifier:[FSCategoriesController storyboardIdentifier]];
    CategoriesDataSource *dataSource = [[CategoriesDataSource alloc] initWithCategoriesDictionary:categoriesInfo];
    [vc setDataSource:dataSource];
    self.categoriesController = vc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.placesController presentViewController:vc animated:YES completion:nil];
    });
}

#pragma mark - 
- (void)requestVenuesForCategoryIds:(NSArray *)categoryIds
{
    runningCategoryRequestsCount = categoryIds.count;
    NSInteger limit = [[FSRecommender sharedRecomender] testVenuesCountToFetch] / categoryIds.count;
    for (NSString *categoryId in categoryIds) {
        [[FSConnectionManager sharedManager] findNearVenuesForCategoryId:categoryId limit:limit];
    }
}

#pragma mark - Alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self setVenuesToShow:self.venuesForRecommendation];
        self.venuesForRecommendation = nil;
    }
}

@end