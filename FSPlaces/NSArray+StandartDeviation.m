//
//  NSArray+StandartDeviation.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "NSArray+StandartDeviation.h"

@implementation NSArray (StandartDeviation)

- (NSNumber *)standartDeviation
{
    NSExpression *expression = [NSExpression expressionForFunction:@"stddev:"
                                                         arguments:@[[NSExpression expressionForConstantValue:self]]];
    return [expression expressionValueWithObject:nil context:nil];
}

@end
