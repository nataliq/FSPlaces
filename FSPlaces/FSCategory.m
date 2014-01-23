//
//  FSCategory.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSCategory.h"
#define PhotoSize @"88"

@implementation FSCategory

- (id)initWithId:(NSString *)identifier name:(NSString *)name primary:(BOOL)primary
{
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.name = name;
        self.primary = primary;
    }
    return self;
}

+ (FSCategory *)initFromParsedJSON:(NSDictionary *)json
{
    FSCategory *category = [[FSCategory alloc] initWithId:json[@"id"]
                                                     name:json[@"shortName"] ?: json[@"name"]
                                                  primary:[json[@"primary"] boolValue]];
    [category initPhotoURLFromParsedJSON:json[@"icon"]];
    return category;
}

- (void)initPhotoURLFromParsedJSON:(NSDictionary *)json
{
    self.photoURL = [NSString stringWithFormat:@"%@bg_%@%@", json[@"prefix"], PhotoSize, json[@"suffix"]];
    
}

- (BOOL)isEqual:(FSCategory *)otherCategory
{
    return [self.identifier isEqual:otherCategory.identifier];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

@end
