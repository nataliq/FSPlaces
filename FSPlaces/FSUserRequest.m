//
//  FSUserRequest.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSUserRequest.h"
#import "FSConnectionManager.h"

#define FS_CURRENT_USER_FORMAT      @"https://api.foursquare.com/v2/users/self?oauth_token=%@"

@implementation FSUserRequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithURL:[FSUserRequest getURL]];
    if (self) {
    }
    return self;
}

+ (NSURL *)getURL
{
    NSString *userURL = [NSString stringWithFormat:FS_CURRENT_USER_FORMAT, [[FSConnectionManager sharedManager] accessToken]];
    
    return [NSURL URLWithString:userURL];
}


@end
