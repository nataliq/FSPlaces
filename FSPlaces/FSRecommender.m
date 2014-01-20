//
//  FSRecommender.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSRecommender.h"
#import "FSConnectionManager.h"
#import "FSVenue.h"

@interface FSRecommender ()

@property (strong, nonatomic) NSMutableSet *venuesTrainingSet;
@property (strong, nonatomic) NSMutableSet *venuesTestSet;

@end

@implementation FSRecommender;

static FSRecommender* sharedRecomender = nil;

#pragma mark - Initialization
+ (FSRecommender *)sharedRecomender
{
    if (!sharedRecomender) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedRecomender = [[FSRecommender alloc] init];
            
        });
    }
    return sharedRecomender;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.venuesTrainingSet = [NSMutableSet set];
        self.venuesTestSet = [NSMutableSet set];
    }
    return self;
}

#pragma mark - Public API

- (void)addVenuesToTrainingSet:(NSArray *)venues
{
    [self.venuesTrainingSet addObjectsFromArray:venues];
}

- (void)addVenuesToTestSet:(NSArray *)venues
{
    [self.venuesTestSet addObjectsFromArray:venues];
}

- (NSArray *)filteredCategoryIdsForTestSet
{
    NSArray *categoriesArrays = [self.venuesTrainingSet.allObjects valueForKeyPath:@"@unionOfObjects.categories"];
    NSArray *categoriesFlatten = [categoriesArrays valueForKeyPath:@"@unionOfArrays.self"];
    NSMutableArray *categoryIds = [NSMutableArray arrayWithArray:[categoriesFlatten valueForKeyPath:@"@unionOfObjects.identifier"]];
    
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:categoryIds];
    
    [categoryIds sortUsingFunction:countedSort context:(__bridge void *)(countedSet)];
    NSArray *filteredCategories = [[NSArray arrayWithArray:categoryIds] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    
    return [filteredCategories subarrayWithRange:NSMakeRange(0, MIN(20, floor(0.3 * filteredCategories.count)))];
    
}

- (NSArray *)filteredItemsToRecommend
{
    NSMutableSet *intersectionBetweenSets = [[NSMutableSet alloc] initWithSet:self.venuesTrainingSet];
    [intersectionBetweenSets intersectSet:self.venuesTestSet];
    
    NSMutableArray *venuesToRecommend = [NSMutableArray array];
    for (FSVenue *venue in intersectionBetweenSets) {
        if (venue.beenHereCount == 0) {
            [venuesToRecommend addObject:venue];
        }
    }
    
    NSArray *nearestVenues = [self.venuesTestSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(FSVenue *v1, FSVenue *v2) {
        return (NSComparisonResult) [@(v1.distance) compare:@(v2.distance)];;
    }];
    [venuesToRecommend addObjectsFromArray:[nearestVenues subarrayWithRange:NSMakeRange(0, MIN(50, floor(0.2 * nearestVenues.count)))]];
    
    return venuesToRecommend;
}

NSInteger countedSort(id obj1, id obj2, void *context) {
    NSCountedSet *countedSet = (__bridge NSCountedSet *)(context);
    NSUInteger obj1Count = [countedSet countForObject:obj1];
    NSUInteger obj2Count = [countedSet countForObject:obj2];
    
    if (obj1Count > obj2Count) return NSOrderedAscending;
    else if (obj1Count < obj2Count) return NSOrderedDescending;
    return NSOrderedSame;
}


@end
