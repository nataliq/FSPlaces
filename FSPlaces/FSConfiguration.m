//
//  FSConfiguration.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSConfiguration.h"

NSString* const FSNotificationLocationServicesAreEnabled = @"FSNotificationLocationEnabled";
NSString* const FSNotificationShowProfile = @"FSNotificationShowProfile";
NSString* const FSNotificationVenuesRequestResolved = @"GetVenuesRequestResolved";
NSString* const FSNotificationCheckinsRequestResolved = @"GetCheckedVenuesRequestResolved";

NSString* const FSNotificationShowProfileKey = @"showProfile";

NSString* const FSBaseUserlessURLFormat = @"https://api.foursquare.com/v2%@?client_secret=%@&client_id=%@&v=20140110";
NSString* const FSBaseURLFormat = @"https://api.foursquare.com/v2/users/self%@?oauth_token=%@&v=20140110";

