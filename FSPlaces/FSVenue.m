//
//  FSVenue.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSVenue.h"
#import "FSCategory.h"

@implementation FSVenue

- (FSVenue *)initFromParsedJSON:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {

        self.name = [json objectForKey:@"name"];
        self.identifier = [json objectForKey:@"id"];
        self.beenHereCount = [[json objectForKey:@"been_here"] integerValue];
        
        NSDictionary *statisticsInfo = [json objectForKey:@"stats"];
        [self initStatistics:statisticsInfo];
        
        NSDictionary *locationInfo = [json objectForKey:@"location"];
        [self initLocation:locationInfo];

        self.urlAddress = [json objectForKey:@"url"];
        
        NSArray *categories = [json objectForKey:@"categories"];
        [self initCategoryNames: categories];
    }
    
    return self;

}

- (void)initStatistics:(NSDictionary *)statisticsInfo
{
    self.checkinsCount = [statisticsInfo[@"checkinsCount"] integerValue];
    self.tipCount = [statisticsInfo[@"tipCount"] integerValue];
    self.usersCount = [statisticsInfo[@"usersCount"] integerValue];
}

- (void)initLocation:(NSDictionary *)locationInfo
{
    self.location = [[CLLocation alloc] initWithLatitude:[[locationInfo objectForKey:@"lat"] floatValue] longitude:[[locationInfo objectForKey:@"lng"] floatValue]];
    self.distance = [[locationInfo objectForKey:@"distance"] floatValue];
    self.address = [locationInfo objectForKey:@"address"];
}

- (void)initCategoryNames:(NSArray *)categoriesData
{
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:categoriesData.count];
    
    for (NSDictionary *category in categoriesData) {
        [categories addObject:[FSCategory initFromParsedJSON:category]];
    }
    self.categories = [NSArray arrayWithArray:categories];

}

- (NSString *)categoriesNames
{
    if (_categories) {
        NSMutableString *subtitleString = [NSMutableString string];
        for (FSCategory *category in _categories) {
            [subtitleString appendFormat:@"%@, ", category.name];
        }
        if (subtitleString.length>0) {
            return [subtitleString substringToIndex:subtitleString.length-2];
        }
    }
    return nil;
}

- (FSCategory *)primaryCategory
{
    NSInteger primaryCategoryIndex = [self.categories indexOfObjectPassingTest:^BOOL(FSCategory *category, NSUInteger idx, BOOL *stop) {
        return category.primary == YES;
    }];
    if (primaryCategoryIndex != NSNotFound) {
        return self.categories[primaryCategoryIndex];
    }
    else {
        return nil;
    }
}

- (CGFloat)proportionBetweenCheckinsAndUsersCount
{
    return (float)self.usersCount / (float)self.checkinsCount;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Name: %@,Distance: %.2f, Categories: %@, Been here: %d, Users: %d, Checkins: %d, Proportion: %f",
            self.name, self.distance, self.categoriesNames, self.beenHereCount, self.usersCount, self.checkinsCount, self.proportionBetweenCheckinsAndUsersCount];
}

- (BOOL)isEqual:(FSVenue *)otherVenue
{
    BOOL isEqual = [self.identifier isEqual:otherVenue.identifier];

    return isEqual;
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

@end
