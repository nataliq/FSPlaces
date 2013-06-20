//
//  UIAlertView+FSAlerts.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "UIAlertView+FSAlerts.h"

@implementation UIAlertView (FSAlerts)

+ (UIAlertView *)noVenuesAlert
{
    return [[UIAlertView alloc] initWithTitle:@"Can't Find Venues" message:@"Check your internet connection and reload the map." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

+ (UIAlertView *)locationErrorAlert
{
    return [[UIAlertView alloc] initWithTitle:@"Can't Determinate Location" message:@"Turn on location services to find venues near by you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

@end
