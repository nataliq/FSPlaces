//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "ProfileSwipeView.h"
#import <QuartzCore/QuartzCore.h>

#import "FSUser.h"

@interface ProfileSwipeView ()

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) BOOL downDirection;
@property (nonatomic) BOOL isMoving;


@end

@implementation ProfileSwipeView


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// When a touch starts, get the current location in the view
    
	self.currentPoint = [[touches anyObject] locationInView:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSNotificationShowProfile object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:FSNotificationShowProfileKey]];
    
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    self.isMoving = YES;
	CGPoint activePoint = [[touches anyObject] locationInView:self];
    
	// Determine new point based on where the touch is now located
	CGPoint newPoint = CGPointMake(self.center.x,
                                   self.center.y + (activePoint.y - self.currentPoint.y));
    
    self.downDirection = activePoint.y > self.currentPoint.y;
    
    
    
    CGSize superviewSize = self.bounds.size;
    
	float midPointY = CGRectGetMidY(self.bounds);
    
    if (newPoint.y > superviewSize.height  - midPointY)
        newPoint.y = midPointY;
	else if (newPoint.y < - midPointY + self.footerView.bounds.size.height)
        newPoint.y = - midPointY + self.footerView.bounds.size.height;
    
	// Set new center location
	self.center = newPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self positionView: (self.isMoving) ? self.downDirection : !self.isShown];
    self.isMoving = NO;
}

- (void)positionView:(BOOL)down
{
    CGPoint newPoint;
    
    float midPointY = CGRectGetMidY(self.bounds);
    
    if (down) {
        newPoint = CGPointMake(self.center.x, midPointY);
    }
    else 
        newPoint = CGPointMake(self.center.x, - midPointY + self.footerView.bounds.size.height);
    
    [self rotateArrowDown:!down];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^(){
        self.center = newPoint;
    }completion:nil ];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FSNotificationShowProfile object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:down] forKey:FSNotificationShowProfileKey]];
    
    self.isShown = down;

}


- (void)rotateArrowDown:(BOOL)down
{
    [UIView animateWithDuration:0.5 animations:^() {
        float angle = (down) ? 0 : M_PI;
        self.arrowImageView.transform = CGAffineTransformMakeRotation(angle);
    }];
}

#pragma mark - Swipe view protocol
- (void)swipeUp
{
    [self positionView:NO];
}

- (void)swipeDown
{
    [self positionView:YES];
}

- (void)setSwipingEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}


@end
