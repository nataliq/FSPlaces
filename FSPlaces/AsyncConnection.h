//
//  AsyncConnection.h
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncConnection : NSObject

typedef void (^ComplitionBlock)();

@property (nonatomic, strong) NSURL* url;
@property (readwrite, copy) ComplitionBlock block;

- (id)initWithUrl:(NSURL*)url andComplitionBlock:(ComplitionBlock)block;

@end
