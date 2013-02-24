//
//  FSUser.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSUser : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *fName;
@property (strong, nonatomic) NSString *lName;
@property (strong, nonatomic) NSString *photoURL;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *facebook;
@property (strong, nonatomic) NSString *email;

@end
