//
//  FSCheckInPostRequest.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 7/4/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSCheckInPostRequest.h"
#import "FSConnectionManager.h"
#import "FSParser.h"
#import "UIAlertView+FSAlerts.h"

#define FS_CHECKIN_FORMAT @"https://api.foursquare.com/v2/checkins/add?oauth_token=%@&v=20140110"

@interface FSCheckInPostRequest ()

@property (strong, nonatomic, readwrite) NSDictionary *params;

@end

@implementation FSCheckInPostRequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithURL:[FSCheckInPostRequest postURL]];
    if (self) {
        self.params = params;
        self.HTTPMethod = @"POST";
        [self setupPostRequestWithParams:params];
        self.handlerBlock = [self complitionBlock];
    }
    return self;
}

- (void)setupPostRequestWithParams:(NSDictionary *)params
{
    NSString *paramString = [NSString stringWithFormat:@"venueId=%@", params[@"venueId"]];
    
    NSData *data = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    [self addValue:@"8bit" forHTTPHeaderField:@"Content-Transfer-Encoding"];
    [self addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [self addValue:[NSString stringWithFormat:@"%i", [data length]] forHTTPHeaderField:@"Content-Length"];
    [self setHTTPBody:data];

}

- (ComplitionHandler)complitionBlock
{
    return ^(NSURLResponse *response, NSData *data, NSError *error) {
            if ([data length] > 0 && !error ) {
                
                NSDictionary *parsedData = [FSParser parseJsonResponse:data error:error];
                BOOL success = parsedData[@"checkin"] != nil;
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[UIAlertView checkedInAlertForVenue:self.params[@"venueName"] success:success] show];
                });
            }
            else if (error){
                NSLog(@"Error: %@", error.debugDescription);
            }
    };
}

+ (NSURL *)postURL
{
    NSString *userURL = [NSString stringWithFormat:FS_CHECKIN_FORMAT, [[FSConnectionManager sharedManager] accessToken]];
    
    return [NSURL URLWithString:userURL];
}

@end
