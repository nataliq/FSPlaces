//
//  FSConnectionManager.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "FSConnectionManagerDelegate.h"

@class User;

@interface FSConnectionManager : NSObject

@property (weak, nonatomic) id<FSConnectionManagerDelegate> delegate;
@property (strong, nonatomic, readonly) NSString *clientID;
@property (strong, nonatomic, readonly) NSString *clientSecret;

+ (FSConnectionManager *)sharedManager;

- (NSString *)accessToken;
- (BOOL)isActive;

- (NSURLRequest *)tokenRequest;
- (BOOL)extractTokenFromResponseURL:(NSURL *)url;
- (FSUser *)requestCurrentUserInformation;
- (void)cancelConnection;

- (void)findVenuesNearby:(CLLocation *)location limit:(int) limit searchterm:(NSString*) searchterm;
- (void)findVenuesNearbyMeWithLimit:(int)limit;
- (void)findCheckedInVenues;


@end
