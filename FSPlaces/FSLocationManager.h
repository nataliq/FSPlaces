//
//  FSLocationManager.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface FSLocationManager : NSObject

+ (FSLocationManager *)sharedManager;

- (CLLocation *)getCurrentLocation;

@end
