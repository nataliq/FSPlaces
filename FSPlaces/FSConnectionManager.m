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
#import "UIAlertView+FSAlerts.h"
#import <FSOAuth/FSOAuth.h>

#define TOKEN_KEY                   @"access_token"
#define FS_AUTHENTICATE_FORMAT      @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@"

@interface FSConnectionManager () 

@property (strong, nonatomic) User *user;

@property (strong, nonatomic, readwrite) NSString *clientID;
@property (strong, nonatomic, readwrite) NSString *clientSecret;
@property (strong, nonatomic, readwrite) NSString *callbackURI;

@end

@implementation FSConnectionManager

static FSConnectionManager* sharedManager = nil;
static NSInteger startedRequestsForCategories = 0;

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
        self.callbackURI = [dictPlist objectForKey:@"callbackURI"];
        
        self.delegate = [FSMediator sharedMediator];
    }
    
	return self;
}

#pragma mark - Application token

- (void)handleFSOAuthURL:(NSURL *)url
{
    FSOAuthErrorCode *errorCode = nil;
    NSString *accessCode = [FSOAuth accessCodeForFSOAuthURL:url error:errorCode];
    [FSOAuth requestAccessTokenForCode:accessCode
                              clientId:self.clientID
                     callbackURIString:self.callbackURI
                          clientSecret:self.clientSecret
                       completionBlock:^(NSString *authToken, BOOL requestCompleted, FSOAuthErrorCode errorCode) {
                           if (requestCompleted && errorCode == FSOAuthErrorNone) {
                               [self saveTokenKey:authToken];
                           }
                       }];
}

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
    NSString *authenticateURLString = [NSString stringWithFormat:FS_AUTHENTICATE_FORMAT, self.clientID, self.callbackURI];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
}

- (BOOL)extractTokenFromResponseURL:(NSURL *)url
{
    NSString *URLString = [url absoluteString];
    
    if ([URLString rangeOfString:TOKEN_KEY].location != NSNotFound) {
        NSString *authToken = [[URLString componentsSeparatedByString:@"="] lastObject];
        [self saveTokenKey:authToken];
        return YES;
    }
    else return NO;
}

- (void)saveTokenKey:(NSString *)toknKey
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:toknKey forKey:TOKEN_KEY];
    [defaults synchronize];
}

#pragma mark - Api methods

- (void)findVenuesNearby:(CLLocation *)location limit:(int)limit searchterm:(NSString *)searchterm categoryId:(NSString *)categoryId
{
    if (location) {
        NSNumber *limitNumber = [NSNumber numberWithInt:limit];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[location, limitNumber, @1000]
                                                                         forKeys:@[@"location", @"limit", @"radius"]];
        if (searchterm) {
            [params setObject:searchterm forKey:@"searchterm"];
        }
        if (categoryId) {
            [params setObject:categoryId forKey:@"categoryId"];
        }
        
        FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeVenue parameters:params];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];

    }
    else [[UIAlertView locationErrorAlert] show];
}

- (void)findVenuesNearbyMeWithLimit:(int)limit
{
   [self findVenuesNearby:[[FSLocationManager sharedManager] getCurrentLocation] limit:limit searchterm:nil categoryId:nil];
}

- (void)findNearVenuesForCategoryId:(NSString *)categoryId
{
    startedRequestsForCategories++;
    [self findVenuesNearby:[[FSLocationManager sharedManager] getCurrentLocation]
                     limit:20 searchterm:nil categoryId:categoryId];
}

- (void)findCheckedInVenues
{
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeCheckinList parameters:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];

}

- (void)getAllCheckinHistory
{
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeHistory parameters:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];
}

- (void)getTODOs
{
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeTODOs parameters:nil];
    
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

- (void)checkInInVenue:(FSVenue *)venue
{
    FSRequest *request = [FSRequestFactoryMethod requestWithType:FSRequestTypeCheckIn
                                                      parameters:@{@"venueId" : venue.identifier,
                                                                 @"venueName" : venue.name}];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:request.handlerBlock];
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
    [[FSMediator sharedMediator] setVenuesToShow:nil];
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
