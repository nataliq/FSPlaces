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
#import "FSVenue+AttributesVector.h"
#import "FSCluster.h"

@interface FSRecommender ()

@property (strong, nonatomic) NSMutableSet *venuesTrainingSet;
@property (strong, nonatomic) NSMutableSet *venuesTestSet;

@property (assign, nonatomic) NSInteger maxUserCount;
@property (assign, nonatomic) NSInteger minUserCount;

@property (strong, nonatomic) NSMutableDictionary *beenHereByCategory;

@end

NSInteger const MaxCategoriesCount = 20;
CGFloat const TrainingTestRatio = 0.4;

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
        self.beenHereByCategory = [NSMutableDictionary dictionary];
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

- (NSInteger)testVenuesCountToFetch
{
    return (self.venuesTrainingSet.count * (1 - TrainingTestRatio) ) / TrainingTestRatio;
}

- (void)analyzeTrainingSet
{
    for (FSVenue *venue in self.venuesTrainingSet) {
        FSCategory *primaryCategory = venue.primaryCategory;
        if (primaryCategory) {
            NSString *primaryCategoryId = primaryCategory.identifier;
            NSNumber *countForCategory = self.beenHereByCategory[primaryCategoryId];
            NSInteger count = [countForCategory integerValue] + venue.beenHereCount;
            [self.beenHereByCategory setObject:@(count) forKey:primaryCategoryId];
        }
    }
}

- (NSDictionary *)trainingCategoriesInfo
{
    return [NSDictionary dictionaryWithObjects:@[self.beenHereByCategory, self.trainingCategories]
                                       forKeys:@[@"counts", @"names"]];
}

- (NSArray *)trainingCategories
{

    NSArray *categoriesArrays = [self.venuesTrainingSet.allObjects valueForKeyPath:@"@unionOfObjects.categories"];
    NSArray *categoriesFlatten = [categoriesArrays valueForKeyPath:@"@unionOfArrays.self"];
    
    return [categoriesFlatten valueForKeyPath:@"@distinctUnionOfObjects.self"];
}

- (NSArray *)filteredCategoryIdsForTestSet
{
    NSArray *sortedCounts = [self.beenHereByCategory.allValues sortedArrayUsingSelector:@selector(compare:)];
    
    CGFloat mean = [[self.beenHereByCategory.allValues valueForKeyPath:@"@sum.integerValue"] floatValue] /
    (float)self.beenHereByCategory.allValues.count;
    
    NSMutableArray *filterdCategories = [NSMutableArray array];
    for (NSNumber *count in [sortedCounts reverseObjectEnumerator]) {
        [filterdCategories addObjectsFromArray:[self.beenHereByCategory allKeysForObject:count]];
        if ([count integerValue] < mean || filterdCategories.count >= MaxCategoriesCount) break;
    }
    
    return filterdCategories;
}

- (NSArray *)filteredItemsToRecommend
{
    NSMutableArray *venuesToRecommend = [NSMutableArray array];
    
    // recommend venues from todo list for sure
    NSMutableSet *intersectionBetweenSets = [[NSMutableSet alloc] initWithSet:self.venuesTrainingSet];
    [intersectionBetweenSets intersectSet:self.venuesTestSet];
    for (FSVenue *venue in intersectionBetweenSets) {
        if (venue.beenHereCount == 0) {
            [venuesToRecommend addObject:venue];
        }
    }
    
    [self.venuesTestSet minusSet:self.venuesTrainingSet];
    
    //    [self clusterizeTestSet];
    [venuesToRecommend addObjectsFromArray:[self evaluateItemsFromTestSet]];
    
    return venuesToRecommend;
}

- (void)clusterizeTestSet
{
    NSArray *nearestVenues = [FSCluster clusterizeAndGetNearestVenues:self.venuesTestSet.allObjects];
    [self.venuesTestSet removeAllObjects];
    [self.venuesTestSet addObjectsFromArray:nearestVenues];
}

- (NSArray *)evaluateItemsFromTestSet
{
    NSMutableSet *allVenues = [[NSMutableSet alloc] initWithSet:self.venuesTrainingSet];
    [allVenues unionSet:self.venuesTestSet];
    self.maxUserCount = [[allVenues.allObjects valueForKeyPath:@"@max.usersCount"] integerValue];
    self.minUserCount = [[allVenues.allObjects valueForKeyPath:@"@min.usersCount"] integerValue];
    
    NSCountedSet *mostSimilarItems = [NSCountedSet set];
    for (FSVenue *trainingVenue in self.venuesTrainingSet) {
        [mostSimilarItems addObjectsFromArray:[self getMostSimilarItemsForItem:trainingVenue count:10]];
    }
    
    NSMutableDictionary *similarityCountDictionary = [NSMutableDictionary dictionaryWithCapacity:mostSimilarItems.count];
    for (NSObject *object in mostSimilarItems) {
        NSInteger count = [mostSimilarItems countForObject:object];
        NSMutableArray *itemsWithEqualSimilarityCount = similarityCountDictionary[@(count)];
        if (!itemsWithEqualSimilarityCount) {
            itemsWithEqualSimilarityCount = [NSMutableArray array];
        }
        [itemsWithEqualSimilarityCount addObject:object];
        [similarityCountDictionary setObject:itemsWithEqualSimilarityCount forKey:@(count)];
    }
    
    NSArray *sortedCounts = [similarityCountDictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *venuesToRecommend = [NSMutableArray array];
    
    for (NSNumber *count in [sortedCounts reverseObjectEnumerator])
    {
        [venuesToRecommend addObjectsFromArray:[similarityCountDictionary objectForKey:count]];
        if (venuesToRecommend.count >= 50 || [count floatValue] == 0) break;
    }
    return venuesToRecommend;
}

- (NSArray *)getMostSimilarItemsForItem:(FSVenue *)item count:(NSInteger)count
{
    NSMutableDictionary *similarityDictionary = [NSMutableDictionary dictionaryWithCapacity:self.venuesTestSet.count];
    NSMutableArray *mostSimilarItems = [NSMutableArray arrayWithCapacity:count];
    
    for (FSVenue *testVenue in self.venuesTestSet) {
        CGFloat similarity = [self checkSimilarityFromItem:item toItem:testVenue];
        NSMutableArray *itemsWithEqualSimilarity = similarityDictionary[@(similarity)];
        if (!itemsWithEqualSimilarity) {
            itemsWithEqualSimilarity = [NSMutableArray array];
        }
        [itemsWithEqualSimilarity addObject:testVenue];
        [similarityDictionary setObject:itemsWithEqualSimilarity forKey:@(similarity)];
    }
    
    NSArray *sortedSimilarities = [similarityDictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSNumber *similarity in sortedSimilarities)
    {
        [mostSimilarItems addObjectsFromArray:[similarityDictionary objectForKey:similarity]];
        if (mostSimilarItems.count >= count || [similarity floatValue] == 0) break;
    }
    
    return mostSimilarItems;
}

- (CGFloat)checkSimilarityFromItem:(FSVenue *)fromItem toItem:(FSVenue *)toItem
{
    return [self checkEuclideanDistanceFromItem:fromItem toItem:toItem];
}

- (CGFloat)checkCosineSimilarityFromItem:(FSVenue *)fromItem toItem:(FSVenue *)toItem
{
    CGFloat theta, nominator = 0, denominator = 0, denominatorFromPart = 0, denominatorToPart = 0;
    
    CGFloat normalizedFromUserCount = ([fromItem.attributesVector[0] floatValue] - self.minUserCount) / (self.maxUserCount - self.minUserCount);
    CGFloat normalizedToUserCount = ([toItem.attributesVector[0] floatValue] - self.minUserCount) / (self.maxUserCount - self.minUserCount);
    
    nominator += normalizedFromUserCount * normalizedToUserCount;
    nominator += [fromItem.attributesVector[1] floatValue] * [toItem.attributesVector[1] floatValue];
    
    denominatorFromPart += normalizedFromUserCount * normalizedFromUserCount;
    denominatorToPart += normalizedToUserCount * normalizedToUserCount;
    
    denominatorFromPart += [fromItem.attributesVector[1] floatValue] * [fromItem.attributesVector[1] floatValue];
    denominatorToPart += [toItem.attributesVector[1] floatValue] * [toItem.attributesVector[1] floatValue];

    denominator = (sqrtf(denominatorFromPart) * sqrtf(denominatorToPart)) ?: 1;
    theta = nominator / denominator;
    NSLog(@"theta: %f", theta);
    return theta;
}

- (CGFloat)checkEuclideanDistanceFromItem:(FSVenue *)fromItem toItem:(FSVenue *)toItem
{
    CGFloat distance = 0;
    
    CGFloat normalizedFromUserCount = ([fromItem.attributesVector[0] floatValue] - self.minUserCount) / (self.maxUserCount - self.minUserCount);
    CGFloat normalizedToUserCount = ([toItem.attributesVector[0] floatValue] - self.minUserCount) / (self.maxUserCount - self.minUserCount);
    distance += (normalizedFromUserCount - normalizedToUserCount) * (normalizedFromUserCount - normalizedToUserCount);
    distance += ([toItem.attributesVector[1] floatValue] - [toItem.attributesVector[1] floatValue]) *
    ([toItem.attributesVector[1] floatValue] - [toItem.attributesVector[1] floatValue]);
    
    CGFloat euclideanDistance = sqrtf(distance);
    NSLog(@"EuclideanDistance: %f", euclideanDistance);
    return euclideanDistance;
}

#pragma mark - Helper functions
NSInteger countedSort(id obj1, id obj2, void *context) {
    NSCountedSet *countedSet = (__bridge NSCountedSet *)(context);
    NSUInteger obj1Count = [countedSet countForObject:obj1];
    NSUInteger obj2Count = [countedSet countForObject:obj2];
    
    if (obj1Count > obj2Count) return NSOrderedAscending;
    else if (obj1Count < obj2Count) return NSOrderedDescending;
    return NSOrderedSame;
}


@end
