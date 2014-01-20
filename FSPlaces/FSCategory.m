//
//  FSCategory.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSCategory.h"

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
    return [[FSCategory alloc] initWithId:json[@"id"]
                                     name:json[@"name"]
                                  primary:[json[@"primary"] boolValue]];
}
@end
