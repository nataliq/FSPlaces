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
#import "AsyncConnection.h"
#import "AppDelegate.h"
#import "User.h"

#define APPDELEGATE (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define CONTEXT [APPDELEGATE managedObjectContext]

#define CLIENT_ID               @"KKC2B024TMDITPJ1XGURM4EAC3DKZFCPWY4Y45DVDZ3KWMHF"
#define CLIENT_SECRET           @"EIFKLIDYZZT50T35RIWNVGNCRDPDZ1A3UR5KKKA1UNW454QD"
#define CALLBACK_URL            @"http://foursquare.webscript.io/"
#define TOKEN_KEY               @"access_token"

#define FS_AUTHENTICATE_FORMAT  @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@"
#define FS_VENUES_FORMAT		@"https://api.foursquare.com/v2/venues/search?client_secret=%@&client_id=%@"
#define FS_CURRENT_USER_FORMAT  @"https://api.foursquare.com/v2/users/self?oauth_token=%@"


@interface FSConnectionManager () 

@property (strong, nonatomic) User *user;

@end

@implementation FSConnectionManager

+ (BOOL)isActive
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY]) {
        return YES;
    }
    return NO;
}

+ (NSString *)accessToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY];
}

+ (NSURLRequest *)tokenRequest
{
    NSString *authenticateURLString = [NSString stringWithFormat:FS_AUTHENTICATE_FORMAT, CLIENT_ID, CALLBACK_URL];
    return [NSURLRequest requestWithURL:[NSURL URLWithString:authenticateURLString]];
}

+ (BOOL)extractTockenFromResponseURL:(NSURL *)url
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

+ (NSArray*) findVenuesNearby:(CLLocation *)location limit:(int) limit searchterm:(NSString*) searchterm
{
	__block NSArray *venues = nil;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:@"Check your internet connection and reload the map" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];

	// Build GET URL
	NSMutableString *venuesURL = [[NSMutableString alloc] initWithFormat:FS_VENUES_FORMAT, CLIENT_SECRET, CLIENT_ID];
	[venuesURL appendFormat:@"&ll=%f,%f", location.coordinate.latitude, location.coordinate.longitude];
	[venuesURL appendFormat:@"&limit=%d", limit];
	if(searchterm != nil) [venuesURL appendFormat:@"&q=%@", searchterm];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:venuesURL]];

    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if ([data length] > 0 && !error ) {
            venues = [FSParser parseVenues:data];
        }
        else if (error){
            //[alert show];
            NSLog(@"Error: %@", error.debugDescription);
        }
    }];
    
    return venues;
}

+ (NSArray*) findVenuesNearbyMeWithLimit:(int)limit
{
   return [self findVenuesNearby:[[FSLocationManager sharedManager] getCurrentLocation] limit:limit searchterm:nil];
}

+ (User *)requestCurrentUserInformation
{
    NSString *userURL = [NSString stringWithFormat:FS_CURRENT_USER_FORMAT, [self accessToken]];
    
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:userURL]];
    
	// Execute URL and read response
    NSError *error;
	NSHTTPURLResponse *httpResponse;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    else if(responseData && httpResponse && [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
    {
        return [FSParser parseUserInformation:responseData];
    }
    
    return nil;

}

+ (void)saveCurrentUser
{
    User *user = [self requestCurrentUserInformation];
    
    AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    User *currentUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc];
    currentUser = user;
    
    [delegate saveContext];

    
}

+ (User *)getUserInfo
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"User" inManagedObjectContext:CONTEXT];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError* error;
    NSArray *arr = [CONTEXT executeFetchRequest:request error:&error];
    
    if (arr && arr.count>0) {
        return [arr objectAtIndex:0];
    }
    
    return nil;

}

+ (void)cancelConnection
{
    [self deleteCurrentUserInfo];
    [self deleteToken];
}

+ (void)deleteCurrentUserInfo
{
    User *user = [self getUserInfo];
    [CONTEXT deleteObject:user];
    
    [APPDELEGATE saveContext];
}

+ (void)deleteToken
{
    if ([self isActive]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN_KEY];
    }
}

@end
