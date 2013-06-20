//
//  FSParser.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FSVenue;
@class FSUser;

@interface FSParser : NSObject

+ (id)parseJsonResponse:(NSData *)data error:(NSError *)error;

+ (NSArray *)venueListFromParsedJSON:(NSDictionary *)json;


@end
