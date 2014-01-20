//
//  FSUser.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSUser.h"

#define UserPhotoSize @"100x100"

@implementation FSUser

- (FSUser *)initFromParsedJSON:(NSDictionary *)json
{
    self = [super init];
    
    if (self) {
        
        NSDictionary *userInfo = [json objectForKey:@"user"];
        
        self.identifier = [userInfo objectForKey:@"id"];
        self.fName = [userInfo objectForKey:@"firstName"];
        self.lName = [userInfo objectForKey:@"lastName"];
        self.city = [userInfo objectForKey:@"homeCity"];
        
        NSDictionary *photoURLComponents = [userInfo objectForKey:@"photo"];
        if (photoURLComponents.allKeys.count == 2) {
            self.photoURL = [NSString stringWithFormat:@"%@%@%@", photoURLComponents[@"prefix"],
                             UserPhotoSize,
                             photoURLComponents[@"suffix"]];
        }
        
        
        NSDictionary *contactInfo = [userInfo objectForKey:@"contact"];
        self.contacts = [ContactInformation initFromParsedJSON:contactInfo];
    }
    
    return self;
}

- (NSString *)fullName
{
    return [NSString stringWithFormat:@"%@ %@", self.fName, self.lName];
}

@end
