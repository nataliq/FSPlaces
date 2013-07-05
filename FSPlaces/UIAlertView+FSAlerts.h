//
//  UIAlertView+FSAlerts.h
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (FSAlerts)

+ (UIAlertView *)noVenuesAlert;
+ (UIAlertView *)locationErrorAlert;
+ (UIAlertView *)checkedInAlertForVenue:(NSString *)venueName success:(BOOL)success;

@end
