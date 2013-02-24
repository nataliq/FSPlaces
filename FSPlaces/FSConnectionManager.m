//
//  FSConnectionManager.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/23/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "FSConnectionManager.h"
#import "FSParser.h"

#define CLIENT_ID               @"KKC2B024TMDITPJ1XGURM4EAC3DKZFCPWY4Y45DVDZ3KWMHF"
#define CLIENT_SECRET           @"EIFKLIDYZZT50T35RIWNVGNCRDPDZ1A3UR5KKKA1UNW454QD"
#define CALLBACK_URL            @"http://foursquare.webscript.io/"
#define FS_AUTHENTICATE_FORMAT  @"https://foursquare.com/oauth2/authenticate?client_id=%@&response_type=token&redirect_uri=%@"
#define TOKEN_KEY               @"access_token"

#define FS_VENUES_FORMAT		@"https://api.foursquare.com/v2/venues/search?client_secret=%@&client_id=%@"

@interface FSConnectionManager () 

@property (strong, nonatomic) FSUser *user;

@end

@implementation FSConnectionManager

+ (BOOL)isActive
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TOKEN_KEY]) {
        return YES;
    }
    return NO;
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
        //TODO completion
        return YES;
    }
    else return NO;
}

+ (NSArray*) findVenuesNearby:(CLLocation *)location limit:(int) limit searchterm:(NSString*) searchterm
{
	NSArray *venues = nil;
    
	// Build GET URL
	NSMutableString *venuesURL = [[NSMutableString alloc] initWithFormat:FS_VENUES_FORMAT, CLIENT_SECRET, CLIENT_ID];
	[venuesURL appendFormat:@"&ll=%f,%f", 42.685685, 23.31];
	[venuesURL appendFormat:@"&limit=%d", limit];
	if(searchterm != nil) [venuesURL appendFormat:@"&q=%@", searchterm];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:venuesURL]];

	// Execute URL and read response
    NSError *error;
	NSHTTPURLResponse *httpResponse;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error.debugDescription);
    }
    else if(responseData && httpResponse && [httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300)
            venues = [FSParser parseVenues:responseData];
			
	
    return venues;
}

+(FSUser *)getUserInfo
{
    return nil;
}

@end
