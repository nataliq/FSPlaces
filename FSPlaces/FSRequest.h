//
//  FSRequest.h
//  FSPlaces
//
//  Created by Natalia Patsovska on 6/19/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSConnectionManagerDelegate.h"

typedef void (^ComplitionHandler)(NSURLResponse *response, NSData *data, NSError *error);

@class FSUser;


@interface FSRequest : NSURLRequest

@property (nonatomic, copy) ComplitionHandler handlerBlock;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, assign) id<FSConnectionManagerDelegate> delegate;

- (instancetype)initWithParameters:(NSDictionary *)params;

+ (NSURL *)getURL;

@end
