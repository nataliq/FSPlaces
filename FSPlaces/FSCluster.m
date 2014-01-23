//
//  FSCluster.m
//  FSPlaces
//
//  Created by Emil Marashliev on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSCluster.h"
#import "FSVenue.h"
#import "FSLocationManager.h"

#define MaxIterationCount 1000

@interface FSCluster ()

@property (strong, nonatomic) NSArray *venuesTestSet;

@property (strong, nonatomic) CLLocation *nearestCentroid;
@property (strong, nonatomic) CLLocation *farestCentroid;

@property (strong, nonatomic) NSMutableArray *nearestVenues;
@property (strong, nonatomic) NSMutableArray *fahrestVenues;

@end

@implementation FSCluster

static FSCluster* sharedCluster = nil;
static BOOL centersAreRecalculated = NO;

#pragma mark - Initialization
+ (FSCluster *)sharedCluster
{
    if (!sharedCluster) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedCluster = [[FSCluster alloc] init];
            
        });
    }
    return sharedCluster;
}

- (id)initWithTestSet:(NSArray *)testSet
{
    self = [super init];
    if (self) {
        self.venuesTestSet = testSet;
        self.nearestVenues = [NSMutableArray array];
        self.fahrestVenues = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public API

+ (NSArray *)clusterizeAndGetNearestVenues:(NSArray *)testVenues
{
    FSCluster *cluster = [[FSCluster alloc] initWithTestSet:testVenues];
    return [cluster clusteringTestSet];
}

#pragma mark - Heplers

- (NSArray *)clusteringTestSet
{
    self.nearestCentroid = [self getNearestClusterCentroidFromTestSet];
    self.farestCentroid = [self getFarestClusterCentroidFromTestSet];
    
    for (FSVenue *venue in self.venuesTestSet) {
        [self addVenueToAppriopriateCluster:venue];
    }
    
    NSInteger currentIteration = 0;
    while (centersAreRecalculated && currentIteration < MaxIterationCount) {
        centersAreRecalculated = NO;
        currentIteration++;
        
        [self moveVenuesBetweenClusters];
    }
    
    //    while ([self isClusterCentroidMoveFrom:nearestCentroid To: [self calculateNewCentroidLocation:nearestVenues]]||
    //            [self isClusterCentroidMoveFrom:farestCentroid To: [self calculateNewCentroidLocation:farestVenues]]) {
    //        nearestCentroid = [self calculateNewCentroidLocation:nearestVenues];
    //        farestCentroid = [self calculateNewCentroidLocation:farestVenues];
    //        nearestVenues = [self getValuesInNearstCentroidWithNearestCentroid:nearestCentroid AndFarestCentroid: farestCentroid];
    //        farestVenues = [self getValuesInFarestCentroidWithNearestCentroid:nearestCentroid AndFarestCentroid: farestCentroid];
    //    }
    return self.nearestVenues;
}

#pragma mark - Calculate centroids
- (CLLocation *)getNearestClusterCentroidFromTestSet
{
    CLLocation *currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    FSVenue *testVenue = self.venuesTestSet[arc4random() % self.venuesTestSet.count];
    CLLocation *nearestClusterCentroidLocation = testVenue.location;
    for (FSVenue *venue in self.venuesTestSet) {
        CLLocationDistance distance= [currentLocation distanceFromLocation: venue.location];
        CLLocationDistance selectDistance = [currentLocation distanceFromLocation:nearestClusterCentroidLocation];
        if (distance < selectDistance) {
            nearestClusterCentroidLocation = venue.location;
        }
        
    }
    return nearestClusterCentroidLocation;
}

- (CLLocation *)getFarestClusterCentroidFromTestSet
{
    CLLocation *currentLocation = [[FSLocationManager sharedManager] getCurrentLocation];
    FSVenue *testVenue = self.venuesTestSet[arc4random() % self.venuesTestSet.count];
    CLLocation *farestClusterCentroidLocation = testVenue.location;
    for (FSVenue *venue in self.venuesTestSet) {
        CLLocationDistance distance= [currentLocation distanceFromLocation: venue.location];
        CLLocationDistance selectDistance = [currentLocation distanceFromLocation:farestClusterCentroidLocation];
        if (distance > selectDistance) {
            farestClusterCentroidLocation = venue.location;
        }
        
    }
    return farestClusterCentroidLocation;
}

- (CLLocation *)calculateNewCentroidLocation:(NSMutableArray *)venuesInCluster
{
    CLLocationDegrees longitude = 0.0;
    CLLocationDegrees latitude = 0.0;
    for(FSVenue * venue in venuesInCluster){
        longitude += venue.location.coordinate.longitude;
        latitude += venue.location.coordinate.latitude;
    }
    
    latitude = latitude / (float)venuesInCluster.count;
    longitude = longitude / (float)venuesInCluster.count;
    CLLocation *newCentroidLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    return newCentroidLocation;
}

- (void)recalculateCentroid:(CLLocation *)centroid
{
    centersAreRecalculated = YES;
    
    if ([centroid isEqual:self.nearestCentroid]) {
        self.nearestCentroid = [self calculateNewCentroidLocation:self.nearestVenues];
    }
    else if ([centroid isEqual:self.farestCentroid]) {
        self.farestCentroid = [self calculateNewCentroidLocation:self.fahrestVenues];
    }
}

- (void)recalculateCentroids
{
    [self recalculateCentroid:self.nearestCentroid];
    [self recalculateCentroid:self.farestCentroid];
}

#pragma mark - Position venue
- (void)addVenueToAppriopriateCluster:(FSVenue *)venue
{
    CLLocationDistance distanceToNearestCentroid = [venue.location distanceFromLocation:self.nearestCentroid];
    CLLocationDistance distanecToFarestCentoid = [venue.location distanceFromLocation:self.farestCentroid];
    if(distanceToNearestCentroid < distanecToFarestCentoid){
        [self.nearestVenues addObject:venue];
        [self recalculateCentroid:self.nearestCentroid];
    }
    else {
        [self.fahrestVenues addObject:venue];
        [self recalculateCentroid:self.farestCentroid];
    }
}

- (void)moveVenuesBetweenClusters
{
    NSMutableArray *venuesToMoveToFahrestSet = [NSMutableArray array];
    for (FSVenue *venue in self.nearestVenues) {
        if ([venue.location distanceFromLocation:self.nearestCentroid] > [venue.location distanceFromLocation:self.farestCentroid]) {
            [venuesToMoveToFahrestSet addObject:venue];
        }
    }
    
    NSMutableArray *venuesToMoveToNearestSet = [NSMutableArray array];
    for (FSVenue *venue in self.fahrestVenues) {
        if ([venue.location distanceFromLocation:self.nearestCentroid] < [venue.location distanceFromLocation:self.farestCentroid]) {
            [venuesToMoveToNearestSet addObject:venue];
        }
    }
    
    [self.nearestVenues removeObjectsInArray:venuesToMoveToFahrestSet];
    [self.fahrestVenues addObjectsFromArray:venuesToMoveToFahrestSet];
    
    [self.fahrestVenues removeObjectsInArray:venuesToMoveToNearestSet];
    [self.nearestVenues addObjectsFromArray:venuesToMoveToNearestSet];
    
    [self recalculateCentroids];
}


//- (NSMutableArray *)getValuesInNearstCentroidWithNearestCentroid: (CLLocation *) nearestLocation AndFarestCentroid: (CLLocation *) farestLocation
//{
//    NSMutableArray *nearestVenues = [[NSMutableArray alloc] init];
//    for(FSVenue *venue in self.venuesTestSet) {
//        CLLocationDistance distanceToNearestCentroid = [venue.location distanceFromLocation: nearestLocation];
//        CLLocationDistance distanecToFarestCentoid = [venue.location distanceFromLocation: farestLocation];
//        if(distanceToNearestCentroid < distanecToFarestCentoid){
//            [nearestVenues addObject:venue];
//        }
//    }
//    return nearestVenues;
//}
//
//- (NSMutableArray *)getValuesInFarestCentroidWithNearestCentroid: (CLLocation *) nearestLocation AndFarestCentroid: (CLLocation *) farestLocation
//{
//    NSMutableArray *farestVenues = [[NSMutableArray alloc] init];
//    for(FSVenue *venue in self.venuesTestSet) {
//        CLLocationDistance distanceToNearestCentroid = [venue.location distanceFromLocation: nearestLocation];
//        CLLocationDistance distanecToFarestCentoid = [venue.location distanceFromLocation: farestLocation];
//        if(distanecToFarestCentoid < distanceToNearestCentroid){
//            [farestVenues addObject:venue];
//        }
//    }
//    return farestVenues;
//}
//
//- (BOOL)isClusterCentroidMoveFrom:(CLLocation*) oldLocation To:(CLLocation *) newLocation
//{
//    BOOL isClusterCentroidMove = YES;
//    //to see if this works
//    if([oldLocation isEqual: newLocation]){
//        isClusterCentroidMove = NO;
//    }
//    return isClusterCentroidMove;
//}

@end
