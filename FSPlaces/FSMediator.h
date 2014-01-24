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
    
} ShowVenuesType;

typedef enum
{
    PlacesViewStyleMap = 0,
    PlacesViewStyleTable
    
} PlacesViewStyle;

@protocol FSMediator <NSObject, CLLocationManagerDelegate, FSConnectionManagerDelegate>

@property (nonatomic, assign) PlacesViewController *placesController;

- (void)updateUserInformation;
- (void)updateLocation;
- (void)profileActionSelected;
- (void)setShownViewStyle:(PlacesViewStyle)shownViewStyle;
- (ShowVenuesType)shownType;
- (void)showVenuesToRecommend;

@end

@interface FSMediator : NSObject <FSMediator>

@property (nonatomic, assign) PlacesViewController *placesController;

+ (FSMediator *)sharedMediator;

@end
