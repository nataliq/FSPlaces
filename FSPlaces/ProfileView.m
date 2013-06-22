//
//  ProfileView.m
//  FSPlaces
//
//  Created by Emil Marashliev on 6/22/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "ProfileView.h"

@interface ProfileView ()

@property (weak, nonatomic) IBOutlet UIImageView *imageVew;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation ProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (void)setUserName:(NSString *)userName
{
    _userName = userName;
    self.userNameLabel.text = userName;
}

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        
        NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.imageVew.image = image;
        });
    });
}

#pragma mark - Populate with information

- (void)populateWithUserInformation:(FSUser *)user
{
    self.imageURL = user.photoURL;
    self.userName = [user fullName];
    
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    float duration = animated ? 1.0 : 0.0;
    
    [UIView animateWithDuration:duration animations:^() {
        self.hidden = hidden;
    }];

}

@end
