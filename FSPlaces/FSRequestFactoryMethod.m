//
//  FSRequestFactoryMethod.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSRequestFactoryMethod.h"

#import "FSUserRequest.h"
#import "FSVenuesRequest.h"
#import "FSCheckinsRequest.h"
#import "FSCheckInPostRequest.h"
#import "FSHistoryRequest.h"
#import "FSTODORequest.h"

@implementation FSRequestFactoryMethod


+ (FSRequest *)requestWithType:(FSRequestType)type parameters:(NSDictionary *)params
{
    switch (type) {
        case FSRequestTypeUser:
            return [[FSUserRequest alloc] initWithParameters:params];
            break;
        case FSRequestTypeVenue:
            return [[FSVenuesRequest alloc] initWithParameters:params];
            break;
        case FSRequestTypeCheckinList:
            return [[FSCheckinsRequest alloc] initWithParameters:params];
            break;
        case FSRequestTypeCheckIn:
            return [[FSCheckInPostRequest alloc] initWithParameters:params];
            break;
        case FSRequestTypeHistory:
            return [[FSHistoryRequest alloc] initWithParameters:params];
            break;
        case FSRequestTypeTODOs:
            return [[FSTODORequest alloc] initWithParameters:nil];
    }
}

@end
