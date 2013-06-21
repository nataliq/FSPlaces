//
//  ProfileSwipeView.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSUser;

@interface ProfileSwipeView : UIView

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *imageURL;
@property (nonatomic) BOOL isShown;

- (void)showAnimated:(BOOL)animated;
- (void)rotateArrowDown:(BOOL)rotate;
- (void)populateWithUserInformation:(FSUser *)user;
- (void)hide;

@end
