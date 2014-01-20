//
//  FSParser.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSParser.h"
#import "FSVenue.h"
#import "FSUser.h"

@implementation FSParser

+ (id)parseJsonResponse:(NSData *)data error:(NSError *)error {
    NSString* responseString = [[NSString alloc]
                                 initWithData:data
                                 encoding:NSUTF8StringEncoding];
    
    if ([responseString isEqualToString:@"true"]) {
        return [NSDictionary dictionaryWithObject:@"true" forKey:@"result"];
    }
    
    if ([responseString isEqualToString:@"false"]) {
        return [NSDictionary dictionaryWithObject:@"false" forKey:@"result"];
    }
    
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    
    NSDictionary *response = [(NSDictionary*)parsedData objectForKey:@"response"];
    
    return response;
}

+ (NSArray *)venueListFromParsedSearchJSON:(NSDictionary *)json
{
    NSArray *venues = json[@"venues"];
    if (venues.count > 0) {
        
        NSMutableArray *parsedVenues = [NSMutableArray array];
        for (NSDictionary *venueInfo in venues) {
            NSMutableDictionary *parsedJSON = [NSMutableDictionary dictionaryWithDictionary:venueInfo];
            [parsedVenues addObject:[[FSVenue alloc] initFromParsedJSON:parsedJSON]];
        }
        return parsedVenues;
    }
    return nil;
}

+ (NSArray *)venueListFromParsedTODOJSON:(NSDictionary *)json
{
    
    NSArray *items = json[@"todos"][@"items"];
    if (items.count > 0) {
        
        NSMutableArray *parsedVenues = [NSMutableArray array];
        for (NSDictionary *itemInfo in items) {
            NSMutableDictionary *parsedJSON = [NSMutableDictionary dictionaryWithDictionary:itemInfo[@"tip"][@"venue"]];
            [parsedVenues addObject:[[FSVenue alloc] initFromParsedJSON:parsedJSON]];
        }
        return parsedVenues;
    }
    return nil;
}

+ (NSArray *)venueListFromParsedJSON:(NSDictionary *)json
{
    NSDictionary *info = nil;
    
    if ([json objectForKey:@"groups"]) {
        info = [[json objectForKey:@"groups"] lastObject];
    }
    else if ([json objectForKey:@"checkins"]) {
        info = [json objectForKey:@"checkins"];
    }
    
    if (nil == info) {
        return nil;
    }
    
    NSArray *items = [info objectForKey:@"items"];
    
    NSMutableArray *parsedVenues = [NSMutableArray array];
    
    for (NSDictionary *venueInfo in items) {
        
        NSDictionary *parsedJSON = venueInfo;
        if ([venueInfo objectForKey:@"venue"]) {
            parsedJSON = [venueInfo objectForKey:@"venue"];
        }
        
        [parsedVenues addObject:[[FSVenue alloc] initFromParsedJSON:parsedJSON]];
    }
    
    return parsedVenues;
}

+ (NSArray *)venueListFromParsedHistoryJSON:(NSDictionary *)json
{
    NSDictionary *venues = json[@"venues"];
    if ([venues[@"count"] integerValue] > 0) {
        
        NSArray *items = venues[@"items"];
        NSMutableArray *parsedVenues = [NSMutableArray array];
        
        for (NSDictionary *venueInfo in items) {
            
            NSMutableDictionary *parsedJSON = [NSMutableDictionary dictionaryWithDictionary:venueInfo[@"venue"]];
            [parsedJSON setObject:venueInfo[@"beenHere"] forKey:@"been_here"];
            
            [parsedVenues addObject:[[FSVenue alloc] initFromParsedJSON:parsedJSON]];
        }
        return parsedVenues;
    }
    return nil;
}

@end
