//
//  UIAlertView+FSAlerts.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "UIAlertView+FSAlerts.h"

@implementation UIAlertView (FSAlerts)

+ (UIAlertView *)alertWithMessage:(NSString *)message
{
    return [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}
+ (UIAlertView *)loginFailureAlert
{
    return [self alertWithMessage:@"Can't login to Foursquare."];
}

+ (UIAlertView *)noVenuesAlert
{
    return [[UIAlertView alloc] initWithTitle:@"Can't Find Venues" message:@"Check your internet connection and reload the map." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

+ (UIAlertView *)locationErrorAlert
{
    return [[UIAlertView alloc] initWithTitle:@"Can't Determinate Location" message:@"Turn on location services to find venues near by you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

+ (UIAlertView *)checkedInAlertForVenue:(NSString *)venueName success:(BOOL)success
{
    NSString *message;
    NSString *title;
    
    if (success) {
        title = @"Success!";
        message = [NSString stringWithFormat:@"You're checked at %@ now.", venueName];
    }
    else {
        title = @"Sorry..";
        message = [NSString stringWithFormat:@"Your attempt to check at %@ failed.", venueName];
    }
    
    return  [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
}

@end
