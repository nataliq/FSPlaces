//
//  FSVenue.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSVenue.h"

@implementation FSVenue

- (FSVenue *)initFromParsedJSON:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {

        self.name = [json objectForKey:@"name"];
        self.identifier = [json objectForKey:@"id"];
        
        NSDictionary *locationInfo = [json objectForKey:@"location"];
        [self initLocation:locationInfo];

        self.urlAddress = [json objectForKey:@"url"];
        
        NSArray *categories = [json objectForKey:@"categories"];
        [self initCategoryNames: categories];
    }
    
    return self;

}

- (void)initLocation:(NSDictionary *)locationInfo
{
    self.location = [[CLLocation alloc] initWithLatitude:[[locationInfo objectForKey:@"lat"] floatValue] longitude:[[locationInfo objectForKey:@"lng"] floatValue]];
    self.distance = [[locationInfo objectForKey:@"distance"] floatValue];
}

- (void)initCategoryNames:(NSArray *)categories
{
    NSMutableArray *categoryNames = [NSMutableArray array];
    
    for (NSDictionary *category in categories) {
        [categoryNames addObject:[category objectForKey:@"name"]];
    }
    self.categoryNames = [NSArray arrayWithArray:categoryNames];

}

- (NSString *)categories
{
    if (_categoryNames) {
        NSMutableString *subtitleString = [NSMutableString string];
        for (NSString *name in _categoryNames) {
            [subtitleString appendFormat:@"%@, ", name];
        }
        if (subtitleString.length>0) {
            return [subtitleString substringToIndex:subtitleString.length-2];
        }
    }
    return nil;
}

@end
