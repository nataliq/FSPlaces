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
#import "NSArray+StandartDeviation.h"

#define MaxIterationCount 10000

@interface FSCluster ()

@property (strong, nonatomic) NSMutableArray *venuesTestSet;

@property (strong, nonatomic) CLLocation *nearestCentroid;
@property (strong, nonatomic) CLLocation *farestCentroid1;
@property (strong, nonatomic) CLLocation *farestCentroid2;

@property (strong, nonatomic) NSMutableArray *nearestVenues;
@property (strong, nonatomic) NSMutableArray *fahrestVenues1;
@property (strong, nonatomic) NSMutableArray *fahrestVenues2;

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
        self.venuesTestSet = [NSMutableArray arrayWithArray:testSet];
        self.nearestVenues = [NSMutableArray array];
        self.fahrestVenues1 = [NSMutableArray array];
        self.fahrestVenues2 = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public API

+ (NSArray *)clusterizeAndGetNearestVenues:(NSArray *)testVenues
{
    FSCluster *cluster = [[FSCluster alloc] initWithTestSet:testVenues];
    [cluster removeOutliers];
    return [cluster clusteringTestSet];
}

#pragma mark - Heplers

- (void)removeOutliers
{
    NSArray *distances = [self.venuesTestSet valueForKeyPath:@"@unionOfObjects.distance"];
    CGFloat maxDistance = 3 * [[distances standartDeviation] floatValue];
    NSIndexSet *indexesOfObjectsToBeRemoved = [self.venuesTestSet indexesOfObjectsPassingTest:^BOOL(FSVenue *venue, NSUInteger idx, BOOL *stop) {
        return venue.distance > maxDistance;
    }];
    
    [self.venuesTestSet removeObjectsAtIndexes:indexesOfObjectsToBeRemoved];
}

- (NSArray *)clusteringTestSet
{
    self.nearestCentroid = [self getNearestClusterCentroidFromTestSet];
    self.farestCentroid1 = [self getFarestClusterCentroidFromTestSet];
    self.farestCentroid2 = [self getOppositeFarestClusterCentroidFromTestSet];
    
    [self addVenuesToAppriopriateCluster:self.venuesTestSet];
    
    NSInteger currentIteration = 0;
    while (centersAreRecalculated && currentIteration < MaxIterationCount) {
        centersAreRecalculated = NO;
        currentIteration++;
        
        [self moveVenuesBetweenClusters];
    }
    NSLog(@"Iterations: %d", currentIteration);
    
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
    return currentLocation;
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
    NSLog(@"Distance between centroids: %f", [self.nearestCentroid distanceFromLocation:farestClusterCentroidLocation]);
    return farestClusterCentroidLocation;
}

- (CLLocation *)getOppositeFarestClusterCentroidFromTestSet
{
    CLLocationDegrees longitude = 2 * self.nearestCentroid.coordinate.longitude - self.farestCentroid1.coordinate.longitude;
    CLLocationDegrees latitude = 2 * self.nearestCentroid.coordinate.latitude - self.farestCentroid1.coordinate.latitude ;
    
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

- (CLLocation *)calculateNewCentroidLocation:(NSMutableArray *)venuesInCluster centroid:(CLLocation *)centroid
{
    CLLocationDegrees longitude = centroid.coordinate.longitude;
    CLLocationDegrees latitude = centroid.coordinate.latitude;
    for(FSVenue * venue in venuesInCluster){
        longitude += venue.location.coordinate.longitude;
        latitude += venue.location.coordinate.latitude;
    }
    
    latitude = latitude / (float)(venuesInCluster.count + 1);
    longitude = longitude / (float)(venuesInCluster.count +1);
    CLLocation *newCentroidLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    
    return newCentroidLocation;
}

- (CLLocation *)recalculateCentroid:(CLLocation *)centroid
{
    centersAreRecalculated = YES;
    return [self calculateNewCentroidLocation:self.nearestVenues centroid:centroid];
}

- (void)recalculateCentroids
{
    self.nearestCentroid = [self recalculateCentroid:self.nearestCentroid];
    self.farestCentroid1 = [self recalculateCentroid:self.farestCentroid1];
    self.farestCentroid2 = [self recalculateCentroid:self.farestCentroid2];
}

#pragma mark - Position venue
- (void)addVenuesToAppriopriateCluster:(NSArray *)venues
{
    for (FSVenue *venue in venues) {
        [self addVenueToAppriopriateCluster:venue];
    }
}

- (void)addVenueToAppriopriateCluster:(FSVenue *)venue
{
    CLLocationDistance distanceToNearestCentroid = [venue.location distanceFromLocation:self.nearestCentroid];
    CLLocationDistance distanecToFarestCentoid1 = [venue.location distanceFromLocation:self.farestCentroid1];
    CLLocationDistance distanecToFarestCentoid2 = [venue.location distanceFromLocation:self.farestCentroid2];
    
    if(distanceToNearestCentroid < MIN(distanecToFarestCentoid1, distanecToFarestCentoid2)){
        [self.nearestVenues addObject:venue];
        self.nearestCentroid = [self recalculateCentroid:self.nearestCentroid];
    }
    else if (distanecToFarestCentoid1 < distanecToFarestCentoid2){
        [self.fahrestVenues1 addObject:venue];
        self.farestCentroid1 = [self recalculateCentroid:self.farestCentroid1];
    }
    else {
        [self.fahrestVenues2 addObject:venue];
        self.farestCentroid2 = [self recalculateCentroid:self.farestCentroid2];
    }
}

- (void)moveVenuesBetweenClusters
{
    NSMutableArray *venuesToMove = [NSMutableArray array];
    
    
    NSMutableArray *venuesToRemoveFromNearest = [NSMutableArray array];
    for (FSVenue *venue in self.nearestVenues) {
        if ([venue.location distanceFromLocation:self.nearestCentroid] >
            MIN([venue.location distanceFromLocation:self.farestCentroid1], [venue.location distanceFromLocation:self.farestCentroid2])) {
            [venuesToRemoveFromNearest addObject:venue];
            [venuesToMove addObject:venue];
        }
    }
    
    NSMutableArray *venuesToRemoveFromFahrest1 = [NSMutableArray array];
    for (FSVenue *venue in self.fahrestVenues1) {
        if ([venue.location distanceFromLocation:self.farestCentroid1] >
            MIN([venue.location distanceFromLocation:self.nearestCentroid], [venue.location distanceFromLocation:self.farestCentroid2])) {
            [venuesToRemoveFromFahrest1 addObject:venue];
            [venuesToMove addObject:venue];
        }
    }
    
    NSMutableArray *venuesToRemoveFromFahrest2 = [NSMutableArray array];
    for (FSVenue *venue in self.fahrestVenues2) {
        if ([venue.location distanceFromLocation:self.farestCentroid2] >
            MIN([venue.location distanceFromLocation:self.nearestCentroid], [venue.location distanceFromLocation:self.farestCentroid1])) {
            [venuesToRemoveFromFahrest2 addObject:venue];
            [venuesToMove addObject:venue];
        }
    }
    
    [self.nearestVenues removeObjectsInArray:venuesToRemoveFromNearest];
    [self.fahrestVenues1 removeObjectsInArray:venuesToRemoveFromFahrest1];
    [self.fahrestVenues2 removeObjectsInArray:venuesToRemoveFromFahrest2];
    
    [self addVenuesToAppriopriateCluster:venuesToMove];
    
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
