//
//  FSRecommender.h
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSRecommender : NSObject

+ (FSRecommender *)sharedRecomender;

- (void)addVenuesToTrainingSet:(NSArray *)venues;
- (void)addVenuesToTestSet:(NSArray *)venues;

- (NSArray *)filteredCategoryIdsForTestSet;
- (NSArray *)filteredItemsToRecommend;

@end
