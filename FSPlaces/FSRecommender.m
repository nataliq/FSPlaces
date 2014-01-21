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

@interface FSRecommender ()

@property (strong, nonatomic) NSMutableSet *venuesTrainingSet;
@property (strong, nonatomic) NSMutableSet *venuesTestSet;

@property (assign, nonatomic) NSInteger maxUserCount;
@property (assign, nonatomic) NSInteger minUserCount;

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
    NSArray *venuesSortedByBeenHereCount = [self.venuesTrainingSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(FSVenue *venue1, FSVenue *venue2) {
        return (NSComparisonResult) [@(venue1.beenHereCount) compare:@(venue2.beenHereCount)];
    }];
    NSArray *topMostVisitedCategories = [[[venuesSortedByBeenHereCount reverseObjectEnumerator] allObjects]
                                         subarrayWithRange:NSMakeRange(0, MIN(70, floor(0.3 * venuesSortedByBeenHereCount.count)))];
    
    NSArray *categoriesArrays = [topMostVisitedCategories valueForKeyPath:@"@unionOfObjects.categories"];
    NSArray *categoriesFlatten = [categoriesArrays valueForKeyPath:@"@unionOfArrays.self"];
    NSMutableArray *categoryIds = [NSMutableArray arrayWithArray:[categoriesFlatten valueForKeyPath:@"@unionOfObjects.identifier"]];
    
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:categoryIds];
    
    [categoryIds sortUsingFunction:countedSort context:(__bridge void *)(countedSet)];
    NSArray *filteredCategories = [[NSArray arrayWithArray:categoryIds] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    
    return [filteredCategories subarrayWithRange:NSMakeRange(0, MIN(20, floor(0.3 * filteredCategories.count)))];
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
            [self.venuesTestSet removeObject:venue];
        }
    }
    
    [self evaluateItemsFromTestSet];
    
    NSArray *nearestVenues = [self.venuesTestSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(FSVenue *v1, FSVenue *v2) {
        return (NSComparisonResult) [@(v1.distance) compare:@(v2.distance)];;
    }];
    [venuesToRecommend addObjectsFromArray:[nearestVenues subarrayWithRange:NSMakeRange(0, MIN(50, floor(0.2 * nearestVenues.count)))]];
    
    return venuesToRecommend;
}

- (void)evaluateItemsFromTestSet
{
    NSMutableSet *allVenues = [[NSMutableSet alloc] initWithSet:self.venuesTrainingSet];
    [allVenues unionSet:self.venuesTestSet];
    self.maxUserCount = [[allVenues.allObjects valueForKeyPath:@"@max.usersCount"] integerValue];
    self.minUserCount = [[allVenues.allObjects valueForKeyPath:@"@min.usersCount"] integerValue];
    
    for (FSVenue *trainingVenue in self.venuesTrainingSet) {
        [self getMostSimilarItemsForItem:trainingVenue count:10];
    }
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
    
    for (NSNumber *similarity in [sortedSimilarities reverseObjectEnumerator])
    {
        [mostSimilarItems addObjectsFromArray:[similarityDictionary objectForKey:similarity]];
        if (mostSimilarItems.count >= count || [similarity floatValue] == 0) break;
    }
    
    return mostSimilarItems;
}

- (CGFloat)checkSimilarityFromItem:(FSVenue *)fromItem toItem:(FSVenue *)toItem
{
    return [self checkCosineSimilarityFromItem:fromItem toItem:toItem];
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
    
    for (NSInteger i = 0; i < fromItem.attributesVector.count; i++) {
        for (NSInteger j = 0; j < toItem.attributesVector.count; j++) {
            CGFloat fromAttribute = [fromItem.attributesVector[i] floatValue];
            CGFloat toAttribute = [toItem.attributesVector[j] floatValue];
            
            distance += (fromAttribute - toAttribute) * (fromAttribute - toAttribute);
        }
    }
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
