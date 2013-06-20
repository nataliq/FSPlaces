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

@end
