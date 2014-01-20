//
//  FSTODORequest.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSTODORequest.h"
#import "FSParser.h"

@implementation FSTODORequest

- (id)initWithParameters:(NSDictionary *)params
{
    self = [super initWithParameters:[FSTODORequest paramsFromParamDictionary:params]];
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
            venueList = [FSParser venueListFromParsedTODOJSON:[FSParser parseJsonResponse:data error:error]];
        }
        else if (error){
            NSLog(@"Error: %@", error.debugDescription);
        }
        [delegate addVenuesForTraining:venueList];
    };
}

+ (NSString *)URLPath
{
    return @"/todos";
}

+ (NSDictionary *)paramsFromParamDictionary:(NSDictionary *)paramDictionary
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:paramDictionary];
    [params setObject:@"recent" forKey:@"sort"];
    return params;
}

@end
