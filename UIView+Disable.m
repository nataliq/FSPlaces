//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "UIView+Disable.h"

@implementation UIView (Disable)

- (void)setDisabled:(BOOL)disabled withAlpha:(float)alpha
{
    self.userInteractionEnabled = !disabled;
    if (disabled) {
        self.alpha = alpha;
    }
    else
        self.alpha = 1;
}

@end
