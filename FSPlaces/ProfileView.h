//
//  ProfileView.h
//  FSPlaces
//
//  Created by Emil Marashliev on 6/22/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSUser.h"

@interface ProfileView : UIView

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *imageURL;

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *footerView;


- (void)populateWithUserInformation:(FSUser *)user;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

@end
