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

+ (NSArray *)parseVenues:(NSData *)data
{
    NSError *myError;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError) {
        NSLog(@"Error: %@", myError.debugDescription);
    }
    
    NSDictionary *response = [(NSDictionary*)parsedData objectForKey:@"response"];
    NSDictionary *group = [[response objectForKey:@"groups"] objectAtIndex:0];
    NSArray *venues = [group objectForKey:@"items"];
    
    NSMutableArray *parsedVenues = [NSMutableArray array];
    for (NSDictionary *venue in venues) {
        [parsedVenues addObject:[FSParser parseVenueInformation:venue]];
    }
    
    return parsedVenues;
}

+ (FSVenue *)parseVenueInformation:(NSDictionary *)venueInfo
{
    FSVenue *venue = [FSVenue new];
    venue.name = [venueInfo objectForKey:@"name"];
    venue.identifier = [venueInfo objectForKey:@"id"];
    
    NSDictionary *locationInfo = [venueInfo objectForKey:@"location"];
    venue.location = [[CLLocation alloc] initWithLatitude:[[locationInfo objectForKey:@"lat"] floatValue] longitude:[[locationInfo objectForKey:@"lng"] floatValue]];
    venue.distance = [[locationInfo objectForKey:@"distance"] floatValue];
    
    NSMutableArray *categoryNames = [NSMutableArray array];
    NSArray *categories = [venueInfo objectForKey:@"categories"];
    for (NSDictionary *category in categories) {
        [categoryNames addObject:[category objectForKey:@"name"]];
    }
    venue.categoryNames = [NSArray arrayWithArray:categoryNames];
    
    return venue;
}


+ (FSUser *)parseUserInformation:(NSData *)data
{
    NSError *myError;
    NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&myError];
    
    if (myError) {
        NSLog(@"Error: %@", myError.debugDescription);
    }
    
    NSDictionary *response = [(NSDictionary*)parsedData objectForKey:@"response"];
    NSDictionary *userInfo = [response objectForKey:@"user"];
   
    FSUser *user = [FSUser new];

    user.identifier = [userInfo objectForKey:@"id"];
    user.fName = [userInfo objectForKey:@"firstName"];
    user.lName = [userInfo objectForKey:@"lastName"];
    user.city = [userInfo objectForKey:@"homeCity"];
    user.photoURL = [userInfo objectForKey:@"photo"];
    
    NSDictionary *contactInfo = [userInfo objectForKey:@"contact"];
    user.facebook = [contactInfo objectForKey:@"facebook"];
    user.email = [contactInfo objectForKey:@"email"];

    NSLog(@"%@, %@, %@", user.fName, user.lName, user.photoURL);
    return user;
}

@end
