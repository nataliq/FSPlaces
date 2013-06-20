//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class FSUser;

@protocol FSConnectionManagerDelegate <NSObject>

- (void)setCurrentUser:(FSUser *)user;
- (void)setVenuesToShow:(NSArray *)venues;
- (void)logIn;
- (void)setLastCheckinLocation:(CLLocation *)location;

@end
