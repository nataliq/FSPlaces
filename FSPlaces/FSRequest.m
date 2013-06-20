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
    self = [self init];
    if (self) {
        self.params = params;
    }
    return self;
}

+ (NSURL *)getURL
{
    //subclasses should override this method
    return nil;
}

@end
