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

@protocol FSMediator <NSObject, CLLocationManagerDelegate, FSConnectionManagerDelegate>

@property (nonatomic, assign) PlacesViewController *mainController;

@end

@interface FSMediator : NSObject <FSMediator>

+ (FSMediator *)sharedMediator;

@property (nonatomic, assign) PlacesViewController *mainController;

@end
