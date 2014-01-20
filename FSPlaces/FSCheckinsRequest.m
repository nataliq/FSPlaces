//
//  FSCheckinsRequest.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSCheckinsRequest.h"
#import "FSConnectionManager.h"
#import "FSParser.h"
#import "FSVenue.h"
#import "UIAlertView+FSAlerts.h"

@implementation FSCheckinsRequest

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
        if ([data length] > 0 && !error ) {
            NSArray *array = [FSParser venueListFromParsedJSON:[FSParser parseJsonResponse:data error:error]];
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                if (array.count>0) {
                    FSVenue *venue = [array objectAtIndex:0];
                    [delegate setLastCheckinLocation:venue.location];
                }
                
                [delegate setVenuesToShow:array];
                [[NSNotificationCenter defaultCenter] postNotificationName:FSNotificationCheckinsRequestResolved object:nil];
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

+ (NSString *)URLPath
{
    return @"/checkins";
}

@end
