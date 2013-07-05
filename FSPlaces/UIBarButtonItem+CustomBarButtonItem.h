//
//  UIBarButtonItem+CustomBarButtonItem.h
//  SportNginMobile
//
//  Created by Natalia Patsovska on 4/22/13.
//  Copyright (c) 2013 Drivetrain Agency LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CustomBarButtonItem)

+ (UIBarButtonItem *)customBarButtonWithImageDefault:(NSString *)imageDefault imageHiglighted:(NSString *)imageHighlighted target:(id)target action:(SEL)selector;
+ (UIBarButtonItem *)customBarButtonWithFrame:(CGRect )frame imageDefault:(NSString *)imageDefault imageHiglighted:(NSString *)imageHighlighted target:(id)target action:(SEL)selector;

@end
