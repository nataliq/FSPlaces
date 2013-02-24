//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "ProfileSwipeView.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileSwipeView ()

@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) BOOL downDirection;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@end

@implementation ProfileSwipeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// When a touch starts, get the current location in the view
    
	self.currentPoint = [[touches anyObject] locationInView:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FSNotificationShowProfile" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"show"]];
    
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint activePoint = [[touches anyObject] locationInView:self];
    CGPoint newPoint = CGPointMake(self.center.x, self.center.y + (activePoint.y - self.currentPoint.y));
    
    float midPointY = CGRectGetMidY(self.bounds);
    
    if (!self.downDirection) {
        newPoint.y = - midPointY + self.footerView.bounds.size.height;
    }
    else
        newPoint.y = midPointY;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FSNotificationShowProfile" object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:self.downDirection] forKey:@"showProfile"]];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^(){
        self.center = newPoint;
    }completion:nil ];
}

-(void) setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(50.0, 50.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}


@end
