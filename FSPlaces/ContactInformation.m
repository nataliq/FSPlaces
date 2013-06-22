//
//  ContactInformation.m
//  FSPlaces
//
//  Created by Emil Marashliev on 6/22/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "ContactInformation.h"

@implementation ContactInformation

- (id)initWithEmail:(NSString *)email facebook:(NSString *)fb
{
    self = [super init];
    if (self) {
        self.email = email;
        self.facebook = fb;
    }
    return self;
}

+ (ContactInformation *)initFromParsedJSON:(NSDictionary *)json
{
    return [[ContactInformation alloc] initWithEmail:json[@"email"]
                                            facebook:json[@"facebook"]];
}

@end
