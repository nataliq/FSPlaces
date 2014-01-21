//
//  FSVenue+AttributesVector.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 1/21/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSVenue+AttributesVector.h"

@implementation FSVenue (AttributesVector)

- (NSArray *)attributesVector
{
    NSArray *attributes = @[@(self.usersCount), @(self.proportionBetweenCheckinsAndUsersCount)];
    return attributes;
}
@end
