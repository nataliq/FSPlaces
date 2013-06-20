//
//  FSMediator.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSMediator.h"
#import "PlacesViewController.h"

@implementation FSMediator

#pragma mark - Singleton

static  FSMediator* sharedMediator = nil;

+ (FSMediator *)sharedMediator
{
    if (!sharedMediator) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedMediator = [[FSMediator alloc] init];
        });
    }
    return sharedMediator;
}

- (id)init {
    
	self = [super init];
	if (self)
    {
        
    }
    
	return self;
}

- (void)setCurrentUser:(FSUser *)user
{
    [self.mainController setCurrentUser:user];
}

- (void)setVenuesToShow:(NSArray *)venues
{
    [self.mainController setVenuesToShow:venues];
}

- (void)logIn
{
    [self.mainController logIn];
}

- (void)setLastCheckinLocation:(CLLocation *)location
{
    [self.mainController setLastCheckinLocation:location];
}

@end
