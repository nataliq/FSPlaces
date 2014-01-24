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

static BOOL userless = NO;
static NSString *urlPath = @"";

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

- (instancetype)initWithURLPath:(NSString *)path userless:(BOOL)haveUser
{
    userless = haveUser;
    urlPath = path;
    
    self = [self initWithURL:[self.class getURLWithParams:nil]];
    if (self) {
    }
    return self;
}

+ (NSString *)URLPath
{
    return urlPath;
}

+ (BOOL)requestIsUserless
{
    return userless;
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
