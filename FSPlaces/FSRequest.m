//
//  FSRequest.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSRequest.h"
#import "PlacesViewController.h"
#import "FSMediator.h"
#import "FSConnectionManager.h"


@interface FSRequest ()

@property (strong, nonatomic, readwrite) NSDictionary *params;

@end

@implementation FSRequest

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = [FSMediator sharedMediator];
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL
{
    self = [super initWithURL:URL];
    if (self) {
        self.delegate = [FSMediator sharedMediator];
    }
    return self;
}

- (instancetype)initWithParameters:(NSDictionary *)params
{
    self = [self initWithURL:[self.class getURLWithParams:params]];
    if (self) {
        self.params = params;
    }
    return self;
}

+ (NSString *)URLPath
{
    //subclasses should override this method
    return nil;
}

+ (BOOL)requestIsUserless
{
    return NO;
}

+ (NSURL *)getURL
{
    return [self getURLWithParams:nil];
}

+ (NSURL *)getURLWithParams:(NSDictionary *)params
{
    if ([self requestIsUserless]) {
        NSString *endpointURLFormat = [self addParameters:params toURLFormat:FSBaseUserlessURLFormat];
        
        return [[NSURL alloc] initWithString:[NSString stringWithFormat:endpointURLFormat, self.URLPath,
                                              [[FSConnectionManager sharedManager] clientSecret],
                                              [[FSConnectionManager sharedManager] clientID]]];
    }
    else {
        NSString *endpointURLFormat = [self addParameters:params toURLFormat:FSBaseURLFormat];
        
        return [[NSURL alloc] initWithString:[NSString stringWithFormat:endpointURLFormat, self.URLPath,
                                              [[FSConnectionManager sharedManager] accessToken]]];
    }
    
}

+ (NSString *)addParameters:(NSDictionary *)parameters toURLFormat:(NSString *)urlFormat
{
    for (NSString *key in parameters) {
        urlFormat = [urlFormat stringByAppendingFormat:@"&%@=%@", key, parameters[key]];
    }
    return urlFormat;
}

@end
