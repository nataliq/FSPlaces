//
//  UIBarButtonItem+CustomBarButtonItem.m
//  SportNginMobile
//
//  Created by Natalia Patsovska on 4/22/13.
//  Copyright (c) 2013 Drivetrain Agency LLC. All rights reserved.
//

#import "UIBarButtonItem+CustomBarButtonItem.h"

@implementation UIBarButtonItem (CustomBarButtonItem)

+ (UIBarButtonItem *)customBarButtonWithImageDefault:(NSString *)imageDefault imageHiglighted:(NSString *)imageHighlighted target:(id)target action:(SEL)selector
{
    return [self customBarButtonWithFrame:CGRectZero imageDefault:imageDefault imageHiglighted:imageHighlighted target:target action:selector];
}

+ (UIBarButtonItem *)customBarButtonWithFrame:(CGRect)frame imageDefault:(NSString *)imageDefault imageHiglighted:(NSString *)imageHighlighted target:(id)target action:(SEL)selector
{
    UIImage *customImageDefault = [UIImage imageNamed:imageDefault];
    UIImage *customImageHighlighted = [UIImage imageNamed:imageHighlighted];
    
    CGRect customButtonFrame;
    if (CGRectIsEmpty(frame)) {
         customButtonFrame = CGRectMake(0, 0, customImageDefault.size.width, customImageDefault.size.height);
    }
    else
        customButtonFrame = frame;
    
    UIButton *customButton = [[UIButton alloc] initWithFrame:customButtonFrame];
    
    [customButton setBackgroundImage:customImageDefault forState:UIControlStateNormal];
    [customButton setBackgroundImage:customImageHighlighted forState:UIControlStateHighlighted];
    [customButton addTarget:target action: selector forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barCustomButton =[[UIBarButtonItem alloc] initWithCustomView:customButton];
    
    return barCustomButton;

}

@end
