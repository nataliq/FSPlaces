//
//  FSRequestFactoryMethod.h
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSRequest.h"

typedef NS_ENUM(NSInteger, FSRequestType) {
    FSRequestTypeUser,
    FSRequestTypeVenue,
    FSRequestTypeCheckinList,
    FSRequestTypeCheckIn,
    FSRequestTypeHistory,
    FSRequestTypeTODOs
};

@interface FSRequestFactoryMethod : NSObject

+ (FSRequest *)requestWithType:(FSRequestType)type parameters:(NSDictionary *)params;

@end
