//
//  FSVenuesRequest.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

#import "FSVenuesRequest.h"
#import "FSParser.h"
#import "FSConnectionManager.h"
#import "UIAlertView+FSAlerts.h"

#define FS_VENUES_FORMAT @"https://api.foursquare.com/v2/venues/search?client_secret=%@&client_id=%@"

@interface FSRequest ()

@property (strong, nonatomic, readwrite) NSDictionary *params;

@end

@implementation FSVenuesRequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithURL:[FSVenuesRequest getURL:params[@"location"] limit:[params[@"limit"] integerValue] searchterm:params[@"searchterm"]]];
    if (self) {
        
        self.params = params;
        
        __block id<FSConnectionManagerDelegate> delegate = self.delegate;
        self.handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
            if ([data length] > 0 && !error ) {
                NSArray * result = [FSParser venueListFromParsedJSON:[FSParser parseJsonResponse:data error:error]];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [delegate setVenuesToShow:result];
                    [delegate setLastCheckinLocation:nil];
                });
                
            }
            else if (error){
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[UIAlertView noVenuesAlert] show];
                });
                
                NSLog(@"Error: %@", error.debugDescription);
            }
        };
    }
    return self;
}

+ (NSURL *)getURL:(CLLocation *)location limit:(int)limit searchterm:(NSString *)searchterm
{
    // Build GET URL
    NSMutableString *venuesURL = [[NSMutableString alloc] initWithFormat:FS_VENUES_FORMAT, [[FSConnectionManager sharedManager] clientSecret], [[FSConnectionManager sharedManager] clientID]];
    [venuesURL appendFormat:@"&ll=%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    [venuesURL appendFormat:@"&limit=%d", limit];
    
    if(searchterm != nil) [venuesURL appendFormat:@"&q=%@", searchterm];
    
    return [NSURL URLWithString:venuesURL];
}

@end
