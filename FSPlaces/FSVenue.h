//
//  FSVenue.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "FSCategory.h"

@interface FSVenue : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic) float distance;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *urlAddress;
@property (assign, nonatomic) NSInteger beenHereCount;
@property (assign, nonatomic) NSInteger checkinsCount;
@property (assign, nonatomic) NSInteger tipCount;
@property (assign, nonatomic) NSInteger usersCount;

- (CGFloat)proportionBetweenCheckinsAndUsersCount;
- (NSString *)categoriesNames;
- (FSCategory *)primaryCategory;
- (FSVenue *)initFromParsedJSON:(NSDictionary *)json;


@end
