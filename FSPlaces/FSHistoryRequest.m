//
//  FSHistoryRequest.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/18/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSHistoryRequest.h"
#import "FSConnectionManager.h"
#import "FSParser.h"
#import "FSVenue.h"

@implementation FSHistoryRequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithParameters:params];
    if (self) {
        self.handlerBlock = [self complitionBlock];
    }
    return self;
}

- (ComplitionHandler)complitionBlock
{
    __block id<FSConnectionManagerDelegate> delegate = self.delegate;
    return ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSArray *venueList = nil;
        if ([data length] > 0 && !error ) {
            venueList = [FSParser venueListFromParsedHistoryJSON:[FSParser parseJsonResponse:data error:error]];
        }
        else if (error){
            NSLog(@"Error: %@", error.debugDescription);
        }
        [delegate addVenuesForTraining:venueList];
    };
}

+ (NSString *)URLPath
{
    return @"/venuehistory";
}

@end
