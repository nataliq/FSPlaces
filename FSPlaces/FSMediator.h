//
//  FSMediator.h
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/20/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "FSConnectionManagerDelegate.h"

@class PlacesViewController;

typedef enum {
    ShowVenuesTypeAround = 0,
    ShowVenuesTypeChecked
}ShowVenuesType;

@protocol FSMediator <NSObject, CLLocationManagerDelegate, FSConnectionManagerDelegate, UIWebViewDelegate>

@property (nonatomic, assign) PlacesViewController *placesController;

- (void)updateUserInformation;
- (void)updateLocation;
- (void)profileActionSelected;
- (ShowVenuesType)shownType;

@end

@interface FSMediator : NSObject <FSMediator>

@property (nonatomic, assign) PlacesViewController *placesController;

+ (FSMediator *)sharedMediator;

@end
