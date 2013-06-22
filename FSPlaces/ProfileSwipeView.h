//
//  ProfileSwipeView.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileView.h"

@protocol SwipeView <NSObject>

- (void)swipeUp;
- (void)swipeDown;
- (void)setSwipingEnabled:(BOOL)enabled;

@end

@interface ProfileSwipeView : ProfileView <SwipeView>

@property (nonatomic) BOOL isShown;

- (void)rotateArrowDown:(BOOL)rotate;
- (void)swipeUp;
- (void)swipeDown;
- (void)setSwipingEnabled:(BOOL)enabled;

@end
