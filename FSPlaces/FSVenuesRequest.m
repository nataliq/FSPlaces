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

@interface FSRequest ()

@property (strong, nonatomic, readwrite) NSDictionary *params;

@end

@implementation FSVenuesRequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithParameters:[FSVenuesRequest paramsFromParamDictionary:params]];
    if (self) {
        __block id<FSConnectionManagerDelegate> delegate = self.delegate;
        self.handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
            NSArray * venueList = nil;
            if ([data length] > 0 && !error ) {
                venueList = [FSParser venueListFromParsedSearchJSON:[FSParser parseJsonResponse:data error:error]];
                if (!params[@"categoryId"]) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        [delegate setLastCheckinLocation:nil];
                        [delegate setVenuesToShow:venueList];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetVenuesRequestResolved" object:nil];
                    }
                                   );
                }
            }
            else if (error) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[UIAlertView noVenuesAlert] show];
                });
                NSLog(@"Error: %@", error.debugDescription);
            }
            if (params[@"categoryId"]) [delegate addVenuesForRecommendation:venueList];
        };
    }
    return self;
}

+ (NSString *)URLPath
{
    return @"/venues/search";
}

+ (BOOL)requestIsUserless
{
    return YES;
}

+ (NSDictionary *)paramsFromParamDictionary:(NSDictionary *)paramDictionary
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:paramDictionary];
    CLLocation *location = params[@"location"];
    [params removeObjectForKey:@"location"];
    [params setObject:[NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude ] forKey:@"ll"];
    
    if (params[@"searchterm"]) {
        [params removeObjectForKey:@"searchterm"];
        [params setObject:paramDictionary[@"searchterm"] forKey:@"q"];
    }
    return params;
}

@end
