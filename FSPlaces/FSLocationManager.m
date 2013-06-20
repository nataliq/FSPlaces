//
//  FSLocationManager.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSLocationManager.h"
#import "FSMediator.h"


@interface FSLocationManager ()

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation FSLocationManager

static  FSLocationManager* sharedManager = nil;

+ (FSLocationManager *)sharedManager
{
    if (!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[FSLocationManager alloc] init];
        });
    }
    return sharedManager;
}

- (id)init {
    
	self = [super init];
	if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = [FSMediator sharedMediator];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager startUpdatingLocation];
    }
    
	return self;
}


- (CLLocation *)getCurrentLocation
{
    return self.locationManager.location;
}

@end
