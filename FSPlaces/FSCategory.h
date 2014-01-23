//
//  FSCategory.h
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/19/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSCategory : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (assign, nonatomic) BOOL primary;
@property (nonatomic, strong) NSString *photoURL;

+ (FSCategory *)initFromParsedJSON:(NSDictionary *)json;

@end
