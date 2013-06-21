//
//  FSConnectionManager.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FSConnectionManager.h"
#import "FSLocationManager.h"
#import "FSParser.h"
#import "AppDelegate.h"
#import "PlacesViewController.h"
#import "FSUser.h"
#import "FSVenue.h"
#import "FSRequestFactoryMethod.h"
#import "FSMediator.h"

#define CALLBACK_URL                @"http://foursquare.webscript.io/"
#define TOKEN_KEY                   @"access_token"

#define FS_AUTHENTICATE_FORMAT      @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@"

@interface FSConnectionManager () 

@property (strong, nonatomic) User *user;

@property (strong, nonatomic, readwrite) NSString *clientID;
@property (strong, nonatomic, readwrite) NSString *clientSecret;


@end

@implementation FSConnectionManager

static  FSConnectionManager* sharedManager = nil;

#pragma mark - Singleton
+ (FSConnectionManager *)sharedManager
{
    if (!sharedManager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[FSConnectionManager alloc] init];
        });
    }
    return sharedManager;
}

- (id)init {
    
	self = [super init];
	if (self)
    {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"clientInfo" ofType:@"plist"];
        NSDictionary *dictPlist = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        self.clientID = [dictPlist objectForKey:@"clientID"];
        self.clientSecret = [dictPlist objectForKey:@"clientSecret"];
        
        self.delegate = [FSMediator sharedMediator];
    }
    
	return self;
}

#pragma mark - Application token

- (BOOL)isActive
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY]) {
        return YES;
    }
    return NO;
}

- (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY];
}

- (NSURLRequest *)tokenRequest
{
    NSString *authenticateURLString = [NSString stringWithFormat:FS_AUTHENTICATE_FORMAT, self.clientID, CALLBACK_URL];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
}

- (BOOL)extractTokenFromResponseURL:(NSURL *)url
{
    NSString *URLString = [url absoluteString];
    
    if ([URLString rangeOfString:TOKEN_KEY].location != NSNotFound) {
        NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:accessToken forKey:TOKEN_KEY];
        [defaults synchronize];
        
        return YES;
    }
    else return NO;
}

#pragma mark - Api methods

- (void) findVenuesNearby:(CLLocation *)location limit:(int)limit searchterm:(NSString *)searchterm
{
    NSNumber *limitNumber = [NSNumber numberWithInt:limit];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[location, limitNumber]
                                                       forKeys:@[@"location", @"limit"]];
    if (searchterm) {
        [params setObject:searchterm forKey:@"searchterm"];
    }
    
	FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeVenue parameters:params];

    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];
}

- (void) findVenuesNearbyMeWithLimit:(int)limit
{
   [self findVenuesNearby:[[FSLocationManager sharedManager] getCurrentLocation] limit:limit searchterm:nil];
}

- (void) findCheckedInVenues
{
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeCheckinList parameters:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];

}

//TODO: make like other requests - async
- (FSUser *)requestCurrentUserInformation
{
	// Execute URL and read response
    NSError *error;
	NSHTTPURLResponse *httpResponse;
    
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeUser parameters:nil];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    else if(responseData && httpResponse && [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
    {
        FSUser *user = [[FSUser alloc] initFromParsedJSON:[FSParser parseJsonResponse:responseData error:error]];
        return user;
    }
    
    return nil;

}

#pragma mark - Cancel connection

- (void)cancelConnection
{
    [self deleteCurrentUserInfo];
    [self deleteToken];
    [self deleteCoockies];
    
    [[FSMediator sharedMediator] updateUserInformation];
}

- (void)deleteCurrentUserInfo
{
//    [self.delegate setCurrentUser:nil];
//    [self.delegate setVenuesToShow:nil];
}

- (void)deleteCoockies
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"foursquare"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)deleteToken
{
    if ([self isActive]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN_KEY];
    }
}


@end
