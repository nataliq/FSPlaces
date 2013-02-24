//
//  FSParser.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSVenue;
@class User;

@interface FSParser : NSObject

+ (NSArray *)parseVenues:(NSData *)data;
+ (User *)parseUserInformation:(NSData *)data;
+ (FSVenue *)parseVenueInformation:(NSDictionary *)venueInfo;

@end
