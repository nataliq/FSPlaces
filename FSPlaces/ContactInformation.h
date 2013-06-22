//
//  ContactInformation.h
//  FSPlaces
//
//  Created by Emil Marashliev on 6/22/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactInformation : NSObject

@property (nonatomic, strong) NSString *facebook;
@property (nonatomic, strong) NSString *email;

- (id)initWithEmail:(NSString *)email facebook:(NSString *)fb;

+ (ContactInformation *)initFromParsedJSON:(NSDictionary *)json;

@end
