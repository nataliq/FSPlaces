//
//  User.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebook;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * lName;
@property (nonatomic, retain) NSString * fName;

@end
