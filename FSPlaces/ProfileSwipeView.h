//
//  ProfileSwipeView.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSwipeView : UIView

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *imageURL;
@property (nonatomic) BOOL isShown;

- (void)rotateArrowDown:(BOOL)rotate;

@end
